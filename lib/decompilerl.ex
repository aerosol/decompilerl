defmodule Decompilerl do
  def decompile(module_or_path_or_tuple, opts \\ []) do
    device = Keyword.get(opts, :device, :stdio)
    skip_info? = Keyword.get(opts, :skip_info, false)

    module_or_path_or_tuple
    |> get_beam()
    |> Enum.map(&do_decompile(&1, skip_info?))
    |> write_to(device)
  end

  defp get_beam(module) when is_atom(module) do
    {^module, bytecode, _file} = :code.get_object_code(module)
    [bytecode]
  end

  defp get_beam(path) when is_binary(path) do
    case Path.extname(path) do
      ".beam" ->
        [String.to_charlist(path)]

      ".ex" ->
        code = File.read!(path)

        for {_module, beam} <- Code.compile_string(code) do
          beam
        end
    end
  end

  defp get_beam({:module, _module, beam, _result}) do
    [beam]
  end

  defp do_decompile(bytecode_or_path, skip_info?) do
    {:ok, {_, [abstract_code: {_, ac}]}} = :beam_lib.chunks(bytecode_or_path, [:abstract_code])
    ac = if skip_info?, do: skip_info(ac), else: ac
    :erl_prettypr.format(:erl_syntax.form_list(ac))
  end

  defp skip_info(ac) do
    ac
    |> Enum.reduce([], fn item, acc ->
      case item do
        {:attribute, _, :export, exports} ->
          exports = exports -- [__info__: 1]
          item = put_elem(item, 3, exports)
          [item | acc]

        {:attribute, _, :spec, {{:__info__, 1}, _}} ->
          acc

        {:function, _, :__info__, 1, _} ->
          acc

        _ ->
          [item | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp write_to(code, device) when is_atom(device) or is_pid(device) do
    IO.puts(device, code)
  end

  defp write_to(code, filename) when is_binary(filename) do
    {:ok, result} =
      File.open(filename, [:write], fn file ->
        IO.binwrite(file, code)
      end)

    result
  end
end
