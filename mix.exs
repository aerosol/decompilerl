defmodule Decompilerl.Mixfile do
  use Mix.Project

  def project do
    [app: :decompilerl,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript,
     deps: deps]
  end

  defp escript do
    [main_module: Decompilerl.CLI, embed_elixir: true]
  end

  def application, do: [applications: []]

  defp deps, do: []
end
