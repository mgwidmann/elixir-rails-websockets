defmodule ElixirRailsWebsockets.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_rails_websockets,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {ElixirRailsWebsockets, []},
     applications: [:phoenix, :cowboy, :logger, :httpoison]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
      {:phoenix, github: "mgwidmann/phoenix", branch: "headers_in_sockets"},
      {:cowboy, "~> 1.0"},
      {:httpoison, "~> 0.5"},
      # Test
      {:mock, "~> 0.1.0", only: :test}
    ]
  end
end
