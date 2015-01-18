defmodule ElixirRailsWebsockets.Endpoint do
  use Phoenix.Endpoint, otp_app: :elixir_rails_websockets

  plug Plug.Static,
    at: "/", from: :elixir_rails_websockets

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_elixir_rails_websockets_key",
    signing_salt: "r8sTHtPP",
    encryption_salt: "IF2wSlh+"

  plug :router, ElixirRailsWebsockets.Router
end
