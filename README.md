# Decompilerl

Decompile Elixir/BEAM to Erlang abstract code.

## CLI

```
$ mix escript.build
Compiled lib/cli.ex
Compiled lib/decompilerl.ex
Generated escript decompilerl with MIX_ENV=dev

$ ./decompilerl

Decompilerl

usage: decompierl <beam_file> [-o <erl_file> | --output=<erl_file>]
```

## Embedded

### Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add decompilerl to your list of dependencies in `mix.exs`:

        def deps do
          [{:decompilerl, "~> 0.0.1"}]
        end

  2. Ensure decompilerl is started before your application:

        def application do
          [applications: [:decompilerl]]
        end

### Usage

```
$ iex -S mix

iex(1)> Decompilerl.decompile(Decompilerl, "/tmp/foo.erl")
```
