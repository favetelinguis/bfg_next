defmodule Nordnetex.MixProject do
  use Mix.Project

  def project do
    [
      app: :nordnetex,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :ssl],
      mod: {Nordnetex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:connection, "~> 1.0.4"},
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false}
    ]
  end
end
