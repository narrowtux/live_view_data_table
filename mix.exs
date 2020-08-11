defmodule LiveViewDataTable.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_view_data_table,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      compilers: [:phoenix] ++ Mix.compilers
    ]
  end

  defp elixirc_paths(:libdev), do: ["lib", "libdev"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.14.0"},
      {:abacus_sql, file: "../abacus_sql"}
    ]
  end
end
