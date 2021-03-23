# Decompilerl

Decompile Elixir/BEAM to Erlang abstract code.

## Why?

When I started working with Elixir, my biggest gripe (coming from the Erlang
world) was that I had no clue what it really compiled to.

This tool aims to provide some answers.

### Sample question: what is a `struct`?

```elixir
defmodule TheStruct do
  defstruct foo: 1

  alias __MODULE__

  def new do
    %TheStruct{foo: 2}
  end
end
```

```elixir
Decompilerl.decompile(TheStruct)
```

```erlang
%% lots of irrelevant stuff...

'__struct__'() ->
    #{'__struct__' => 'Elixir.TheStruct', foo => 1}.

'__struct__'(_@1) ->
    {_@6, _@7} = 'Elixir.Enum':reduce(_@1,
                                      {'__struct__'(), []},
                                      fun ({_@2, _@3}, {_@4, _@5}) ->
                                              {maps:update(_@2, _@3, _@4),
                                               lists:delete(_@2, _@5)}
                                      end),
    case _@7 of
      [] -> _@6;
      _ ->
          erlang:error('Elixir.ArgumentError':exception(<<"the following keys must also be given "
                                                          "when building ",
                                                          "struct ",
                                                          ('Elixir.Kernel':inspect('Elixir.TheStruct'))/binary,
                                                          ": ",
                                                          ('Elixir.Kernel':inspect(_@7))/binary>>))
    end.

new() ->
    #{'__struct__' => 'Elixir.TheStruct', foo => 2,
      '__struct__' => 'Elixir.TheStruct'}.
```

There we go! `struct` is an Erlang map with a special key `__struct__ => ?MODULE`
that allows pattern matching further down the line. Noice!

## Command-line interface

You can build `Decompilerl` as a standalone executable (escript).

```
$ mix escript.build
Compiled lib/cli.ex
Compiled lib/decompilerl.ex
Generated escript decompilerl with MIX_ENV=dev

$ ./decompilerl

Decompilerl

usage: decompierl <file> [-o <erl_file> | --output=<erl_file>]
```

## Usage

By default, `Decompilerl.decompile` spits the Erlang abstract code to stdout.
When provided with a second (optional) argument, it'll dump it to a file.

```
$ iex -S mix

iex(1)> Decompilerl.decompile(Decompilerl, "/tmp/foo.erl")
```
