defmodule Pong.Mixfile do
  use Mix.Project

  def project do
    [app: :pong,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug, :poison],
     mod: {Pong, []}]
  end

  defp deps do
    [
        {:cowboy, "~> 1.0"},
        {:plug, "~> 1.0"},
        {:poison, "~> 2.0"}
    ]
  end
end
