defmodule Decompilerl do

  def summarise(module, device \\ :stdio) do
    obtain_beam(module)
    |> make_summary
    |> format_summary
    |> write_to(device)
  end

  def decompile(module, device \\ :stdio) do
    obtain_beam(module)
    |> do_decompile
    |> write_to(device)
  end

  defp format_summary(map) do
    %{:file       => file,
      :module     => module,
      :behaviours => behaviours,
      :exports    => exports,
      :functions  => functions} = map
    lines = [
      "File         : " <> file,
      "Module       : " <> module,
      format(behaviours, "Behaviours   : "),
      format(exports,    "Exported Fns : "),
      get_private_functions(functions, exports)
      |>format("Private Fns  : ")
    ]
    Enum.join(List.flatten(lines), "\n")
  end


  defp format([], _prefix) do
    []
  end
  defp format(behaviours, prefix) do
    [h | t] = behaviours
    lines = for x <- t, do: "               " <> x
    [prefix <> h] ++ lines
  end

  defp get_private_functions(functions, exports) do
    Enum.drop_while(functions, fn(x) -> Enum.member?(exports, x) end)
  end

  defp make_summary(beam_code) do
    {:ok, {_, [abstract_code: {_, ac}]}} =
      :beam_lib.chunks(beam_code, [:abstract_code])
    {:tree, _, _, ast} = :erl_syntax.form_list(ac)
    map = %{:file       => [],
            :module     => [],
            :behaviours => [],
            :exports    => [],
            :functions  => []}
    Enum.reduce(ast, map, &process_ast/2)
  end

  defp process_ast({:attribute, _, :module, module}, map) do
    Map.put(map, :module, Atom.to_string(module))
  end

  defp process_ast({:attribute, _, :file, {file, _}}, map) do
    Map.put(map, :file, to_string(file))
  end

  defp process_ast({:attribute, _, :export, exports}, map) do
    formatted_exports = for {func, arity} <- exports do
      make_fn_declaration(func, arity)
    end
    append_value(map, :exports, formatted_exports)
  end

  defp process_ast({:attribute, _, :behaviour, behaviour}, map) do
    append_value(map, :behaviours, [Atom.to_string(behaviour)])
  end

  defp process_ast({:function, _, func, arity, _body}, map) do
    append_value(map, :functions, [make_fn_declaration(func, arity)])
  end

  ## dump the rest
  defp process_ast(_clause, map) do
    map
  end

  defp make_fn_declaration(func, arity) do
    Atom.to_string(func) <> "/" <> Integer.to_string(arity)
  end

  defp append_value(map, key, valuelist) when is_list(valuelist) do
    %{^key => values} = map
    Map.put(map, key, values ++ valuelist)
  end

  defp obtain_beam(module) when is_atom(module) do
    {^module, beam, _file} = :code.get_object_code(module)
    beam
  end

  defp obtain_beam(module) when is_binary(module) do
    String.to_char_list(module)
  end

  defp do_decompile(beam_code) do
    {:ok, {_, [abstract_code: {_, ac}]}} =
      :beam_lib.chunks(beam_code, [:abstract_code])
    :erl_prettypr.format(:erl_syntax.form_list(ac))
  end

  defp write_to(code, :stdio) do
    IO.puts code
  end

  defp write_to(code, file_name) when is_binary(file_name) do
    {:ok, result} =
      File.open(file_name, [:write], fn(file) ->
        IO.binwrite(file, code)
      end)
    result
  end
end
