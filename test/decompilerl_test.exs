defmodule DecompilerlTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @outfile "tmp/decompilerl_test.erl"

  test "output to stdout" do
    :ok = Decompilerl.decompile(Decompilerl.CLI)
  end

  test "output to file" do
    File.rm_rf!("tmp")
    File.mkdir_p!("tmp")
    :ok = Decompilerl.decompile(Decompilerl, device: @outfile)
    assert File.exists?(@outfile)
  end

  test "beam file" do
    out =
      capture_io(fn ->
        path = "_build/test/lib/decompilerl/ebin/Elixir.Decompilerl.beam"
        :ok = Decompilerl.decompile(path)
      end)

    assert out =~ "-module('Elixir.Decompilerl')."
  end

  test "elixir file" do
    out =
      capture_io(fn ->
        :ok = Decompilerl.decompile("lib/decompilerl.ex")
      end)

    assert out =~ "-module('Elixir.Decompilerl')."
  end

  test "skip __info__" do
    out =
      capture_io(fn ->
        path = "_build/test/lib/decompilerl/ebin/Elixir.Decompilerl.CLI.beam"
        :ok = Decompilerl.decompile(path, skip_info: true)
      end)

    assert out =~ "-module('Elixir.Decompilerl.CLI')."
    refute out =~ "__info__"
  end
end
