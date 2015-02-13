defmodule ElixirRailsWebsockets.ProxyChannel do
  use Phoenix.Channel
  require Logger

  @data_update "data:update"
  @data :data
  @url  :url
  @timeout_start 100
  @timeout_end   86400000
  @timeout_range @timeout_start..@timeout_end
  @header_exclusions ["connection", "upgrade"]

  def join(timeout, url, socket) do
    case check_timeout(timeout) do
      {:integer, timeout_int} ->
        proxy(url, filter_headers(socket.conn.req_headers), socket, String.to_integer(timeout))
        {:ok, socket}
      :other ->
        {:error, socket, "Not a valid integer within #{@timeout_start}..#{@timeout_end}ms : #{timeout}"}
    end
  end

  def check_timeout(timeout) do
    case :string.to_integer(to_char_list(timeout)) do
      {num, _} when num in @timeout_range -> {:integer, num}
      {num, _}                            -> :other
      {:error, :no_integer}               -> :other
    end
  end

  def filter_headers(headers) do
    _filter_headers(headers, [])
  end

  defp _filter_headers([], filtered) do
    Enum.reverse(filtered)
  end

  defp _filter_headers([{key, _val} = header | rest], filtered) when key in @header_exclusions do
    _filter_headers(rest, filtered)
  end

  defp _filter_headers([header | rest], filtered) do
    _filter_headers(rest, [header | filtered])
  end

  def proxy(url, headers, socket, timeout) do
    url
    |> initialize_socket(headers, socket)
    |> setup_interval(timeout)
    |> reply_with_initial_data
  end

  def initialize_socket(url, headers, socket) do
    Phoenix.Socket.assign(socket, @url, url)
    |> Phoenix.Socket.assign(:headers, headers)
    |> Phoenix.Socket.assign(@data, get(url, headers))
  end

  def reply_with_initial_data(socket) do
    reply socket, @data_update, socket.assigns[@data]
  end

  def setup_interval(socket, timeout) do
    pid = spawn fn ->
      poll(socket)
    end
    :timer.send_interval timeout, pid, :check
    socket
  end

  def get(url, headers) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in [200, 301, 302] ->
        parse(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{error: "Not found: #{url}"}
      # Rails closes the connection after returning the data... :hackney
      # doesn't like this and returns an error instead... the data is right
      # there but it thinks something went wrong...
      {:error, %HTTPoison.Error{reason: {:closed, body}}} ->
        parse(body)
      {:error, %HTTPoison.Error{reason: reason}} ->
        %{error: inspect(reason)}
    end
  end

  def parse(body) do
    case Poison.Parser.parse(body) do
      {:ok, body} when is_map(body) ->
        body
      {:error, {:invalid, "<"}}     -> # HTML
        %{html: body}
      {:error, {reason, message}}   ->
        Logger.debug "Unable to parse as JSON: #{inspect reason} #{message}"
        %{text: body}
      {:error, :invalid} ->
        %{text: body}
    end
  end

  def poll(socket) do
    if Process.alive? socket.pid do
      receive do
        :check ->
          Logger.debug "#{inspect self} Checking #{socket.assigns[@url]}"
          data = get(socket.assigns[@url], socket.assigns[:headers])
          unless data == socket.assigns[@data] do
            Logger.debug "#{inspect self} Data has changed"
            reply(socket, @data_update, data)
            socket = Phoenix.Socket.assign(socket, @data, data)
          end
          poll(socket)
        :exit -> # Used for testing
          # Stop looping
      end
    end
  end

end
