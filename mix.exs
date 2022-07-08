defmodule Vox.MixProject do
  use Mix.Project

  def project do
    [
      app: :vox,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Vox.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.6"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dotenv_parser, "~> 2.0"}
    ]
  end
end
