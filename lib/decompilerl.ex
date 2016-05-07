defmodule Decompilerl do

  def decompile(module, device \\ :stdio) do
    obtain_beam(module)
    |> do_decompile
    |> write_to(device)
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
