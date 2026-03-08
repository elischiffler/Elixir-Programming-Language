defmodule PARSERTest do
  use ExUnit.Case
  doctest PARSER

  test "greets the world" do
    assert PARSER.hello() == :world
  end
end
