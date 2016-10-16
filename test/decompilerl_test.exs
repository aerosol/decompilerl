defmodule DecompilerlTest do
  use ExUnit.Case

  @outfile "decompilerl_test.erl"

  test "Decompile Decompilerl" do
    :ok = Decompilerl.decompile(Decompilerl)
    :ok = Decompilerl.decompile(Decompilerl, @outfile)
    assert File.exists? @outfile
  end
end
