defmodule Decompilerl.CLI do
  @switches help: :boolean, output: :string, summary: :boolean
  @aliases  h: :help, o: :output, s: :summary

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  defp parse_args(args) do
    opts =
      OptionParser.parse(args, switches: @switches, aliases: @aliases)

    {parsed, args, errors} = opts
    case errors do
      [] ->
        case {Enum.sort(parsed), args} do
          {[], [name]} ->
            {:decompile, {name, :stdio}}
          {[output: output], [name]} ->
            {:decompile, {name, output}}
          {[output: output, summary: true], [name]} ->
            {:summarise, {name, output}}
          {[summary: true], [name]} ->
            {:summarise, {name, :stdio}}
        end
      _ ->
        :help
    end
  end

  defp process(:help) do
    IO.puts """
    Decompilerl

    usage: decompierl <beam_file> [-o <erl_file> | --output=<erl_file> | -s | --summary]
    """
  end

  defp process({:decompile, {name, device}}) do
    Decompilerl.decompile(name, device)
  end

  defp process({:summarise, {name, device}}) do
    Decompilerl.summarise(name, device)
  end

end
