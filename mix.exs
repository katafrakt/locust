defmodule Locust.Mixfile do
  use Mix.Project

  def project do
    [app: :locust,
     version: "0.0.1",
     elixir: "~> 1.2",
     escript: [main_module: Locust],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ibrowse, "~> 4.2.2"},
      {:httpotion, "~> 2.1.0"},
      {:progress_bar, "> 0.0.0"},
      {:statistics, "~> 0.6.2"},
      {:credo, "~> 0.4", only: [:dev, :test]}
    ]
  end
end
