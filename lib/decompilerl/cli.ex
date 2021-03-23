defmodule Decompilerl.CLI do
  @switches [
    help: :boolean,
    output: :string,
    skip_info: :boolean
  ]

  @aliases [
    h: :help,
    o: :output
  ]

  def main(args) do
    {opts, argv} = OptionParser.parse!(args, switches: @switches, aliases: @aliases)

    case argv do
      [file] ->
        Decompilerl.decompile(file, opts)

      _ ->
        IO.puts("""
        Decompilerl

        usage: decompilerl <file> [-o <erl_file> | --output=<erl_file> | --skip-info]
        """)

        System.halt(1)
    end
  end
end
