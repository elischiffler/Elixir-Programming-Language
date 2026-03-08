defmodule PARSERTest do
  use ExUnit.Case
  doctest PARSER

  alias SzmxInterpreter.{NumC, IdC, StrC, IfC, LamC, AppC}

  test "parses a number" do
    assert %NumC{n: 5.0} = PARSER.parser("5")
  end

  test "parses a string" do
    ast = PARSER.parser("\"hello\"")
    assert %StrC{s: "hello"} = ast
  end

  test "parses an identifier" do
    assert %IdC{s: "x"} = PARSER.parser("x")
  end

  test "parses an application" do
    ast = PARSER.parser("{+ 1 2}")
    assert %AppC{
      fun: %IdC{s: "+"},
      args: [%NumC{n: 1.0}, %NumC{n: 2.0}]
    } = ast
  end

  test "parses if" do
    ast = PARSER.parser("{if true 1 2}")
    assert %IfC{
      test: %IdC{s: "true"},
      then: %NumC{n: 1.0},
      else: %NumC{n: 2.0}
    } = ast
  end

  test "parses fun" do
    ast = PARSER.parser("{fun (x y) => {+ x y}}")

    assert %LamC{
      params: ["x", "y"],
      body: %AppC{
        fun: %IdC{s: "+"},
        args: [%IdC{s: "x"}, %IdC{s: "y"}]
      }
    } = ast
  end
end
