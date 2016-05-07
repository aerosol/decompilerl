defmodule Decompilerl.CLI do
  @switches help: :boolean, output: :string
  @aliases  h: :help, o: :output

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(args) do
    opts = 
      OptionParser.parse(args, switches: @switches, aliases: @aliases)

    case opts do
      {[], [name], _} -> {name, :stdio}
      {[output: output], [name], _} -> {name, output}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    Decompilerl

    usage: decompierl <beam_file> [-o <erl_file> | --output=<erl_file>]
    """
  end

  def process({name, device}) do
    Decompilerl.decompile(name, device)
  end
end
