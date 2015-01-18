defmodule ElixirRailsWebsockets.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ~w(html json)
  end

  scope "/", ElixirRailsWebsockets do
    pipe_through :api

    get "/interface", PageController, :index

  end

  socket "/ws", ElixirRailsWebsockets do
    channel "*", ProxyChannel
  end

end
