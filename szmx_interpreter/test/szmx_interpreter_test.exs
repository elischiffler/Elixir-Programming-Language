defmodule SzmxInterpreterTest do
  use ExUnit.Case
  doctest SzmxInterpreter

  alias SzmxInterpreter.{NumC, IdC, StrC}

  test "Basic Interp for constants" do
    assert SzmxInterpreter.interp(%NumC{n: 5}, %{}) == 5
    assert SzmxInterpreter.interp(%StrC{s: "hello"}, %{}) == "hello"
  end

  test "Serialization" do
    assert SzmxInterpreter.serialize(5) == "5"
    assert SzmxInterpreter.serialize(true) == "true"
    assert SzmxInterpreter.serialize("hello") == "\"hello\""
  end

  test "Variable lookup in environment" do
    env = %{"x" => 10, "y" => 20}
    assert SzmxInterpreter.interp(%IdC{s: "x"}, env) == 10
  end
end
