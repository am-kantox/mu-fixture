defmodule MuFixture.Mixfile do
  use Mix.Project

  def project do
    [app: :mu_fixture,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :yaml_elixir]]
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
      { :ex_doc, github: "elixir-lang/ex_doc" },
      { :floki, "~> 0.7" },
      { :yaml_elixir, "~> 1.0.0" },
      { :yamerl, github: "yakaz/yamerl" },

      { :credo, "~> 0.2", only: [:dev, :test] },
    ]
  end
end
