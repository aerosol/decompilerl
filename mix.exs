defmodule Decompilerl.Mixfile do
  use Mix.Project

  def project do
    [app: :decompilerl,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Decompile Elixir modules to Erlang abstract code",
     package: package,
     escript: escript,
     deps: deps]
  end

  defp escript do
    [main_module: Decompilerl.CLI, embed_elixir: true]
  end

  def application, do: [applications: []]

  defp deps do
    [{:ex_doc, "~> 0.10", only: :dev}]
  end

  defp package do
    [maintainers: ["Adam Rutkowski"],
     licenses: ["WTFPL"],
     links: %{"GitHub" => "https://github.com/aerosol/decompilerl"}]
  end
end
