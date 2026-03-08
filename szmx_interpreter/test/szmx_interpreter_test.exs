defmodule SzmxInterpreterTest do
  use ExUnit.Case
  doctest SzmxInterpreter

  alias SzmxInterpreter.{NumC, IdC, StrC, IfC, LamC, AppC, NumV, StrV, BoolV, CloV, PrimV}

  describe "Interpretation Logic" do
    test "Basic Interp for constants" do
      assert SzmxInterpreter.interp(%NumC{n: 5}, %{}) == %NumV{n: 5}
      assert SzmxInterpreter.interp(%StrC{s: "hello"}, %{}) == %StrV{s: "hello"}
    end

    test "Variable lookup in environment" do
      env = %{"x" => %NumV{n: 10}, "y" => %NumV{n: 20}}
      assert SzmxInterpreter.interp(%IdC{s: "x"}, env) == %NumV{n: 10}
    end

    test "Variable lookup for boolean" do
      env = %{"flag" => %BoolV{b: false}}
      assert SzmxInterpreter.interp(%IdC{s: "flag"}, env) == %BoolV{b: false}
    end

    test "Function definition and application" do
      # ((fn (x) x) 10)
      expr = %AppC{
        fun: %LamC{params: ["x"], body: %IdC{s: "x"}},
        args: [%NumC{n: 10}]
      }
      assert SzmxInterpreter.interp(expr, %{}) == %NumV{n: 10}
    end

    test "IfC true branch" do
      env = %{"true" => %BoolV{b: true}}
      expr = %IfC{test: %IdC{s: "true"}, then: %NumC{n: 1}, else: %NumC{n: 2}}
      assert SzmxInterpreter.interp(expr, env) == %NumV{n: 1}
    end

    test "IfC false branch" do
      env = %{"false" => %BoolV{b: false}}
      expr = %IfC{test: %IdC{s: "false"}, then: %NumC{n: 1}, else: %NumC{n: 2}}
      assert SzmxInterpreter.interp(expr, env) == %NumV{n: 2}
    end
  end

  describe "Serialization" do
    test "Basic types" do
      assert SzmxInterpreter.serialize(%NumV{n: 5}) == "5"
      assert SzmxInterpreter.serialize(%BoolV{b: true}) == "true"
      assert SzmxInterpreter.serialize(%StrV{s: "hello"}) == "\"hello\""
    end

    test "Serialize Closure" do
      val = %CloV{params: [], body: %NumC{n: 1}, env: %{}}
      assert SzmxInterpreter.serialize(val) == "#<procedure>"
    end

    test "Serialize Primitive" do
      val = %PrimV{op_symbol: "+"}
      assert SzmxInterpreter.serialize(val) == "#<primop>"
    end
  end

  describe "SZMX Errors" do
    test "Unbound variable raises SZMX error" do
      assert_raise RuntimeError, "SZMX Error: Variable z not found in environment", fn ->
        SzmxInterpreter.interp(%IdC{s: "z"}, %{})
      end
    end

    test "IfC non-boolean test error" do
      expr = %IfC{test: %NumC{n: 5}, then: %NumC{n: 1}, else: %NumC{n: 2}}
      assert_raise RuntimeError, "SZMX Error: If test must evaluate to a boolean", fn ->
        SzmxInterpreter.interp(expr, %{})
      end
    end

    test "AppC arity mismatch error" do
      expr = %AppC{
        fun: %LamC{params: ["x"], body: %IdC{s: "x"}},
        args: [%NumC{n: 10}, %NumC{n: 20}]
      }
      assert_raise RuntimeError, "SZMX Error: Mismatch between number of arguments and parameters", fn ->
        SzmxInterpreter.interp(expr, %{})
      end
    end

    test "AppC non-function application error" do
      expr = %AppC{
        fun: %NumC{n: 5},
        args: [%NumC{n: 10}]
      }
      assert_raise RuntimeError, "SZMX Error: Application of non-function", fn ->
        SzmxInterpreter.interp(expr, %{})
      end
    end

    test "Serialize Unknown Type" do
      assert_raise RuntimeError, "SZMX Error: Unknown value type", fn ->
        SzmxInterpreter.serialize(:invalid_thing)
      end
    end
  end

  describe "Primitive Operations" do
    setup do
      {:ok, env: SzmxInterpreter.top_env()}
    end

    test "Addition", %{env: env} do
      expr = %AppC{fun: %IdC{s: "+"}, args: [%NumC{n: 1}, %NumC{n: 2}]}
      assert SzmxInterpreter.interp(expr, env) == %NumV{n: 3}
    end

    test "Subtraction", %{env: env} do
      expr = %AppC{fun: %IdC{s: "-"}, args: [%NumC{n: 10}, %NumC{n: 3}]}
      assert SzmxInterpreter.interp(expr, env) == %NumV{n: 7}
    end

    test "Multiplication", %{env: env} do
      expr = %AppC{fun: %IdC{s: "*"}, args: [%NumC{n: 4}, %NumC{n: 2}]}
      assert SzmxInterpreter.interp(expr, env) == %NumV{n: 8}
    end

    test "Division", %{env: env} do
      expr = %AppC{fun: %IdC{s: "/"}, args: [%NumC{n: 10}, %NumC{n: 2}]}
      assert SzmxInterpreter.interp(expr, env) == %NumV{n: 5.0}
    end

    test "Division by zero", %{env: env} do
      expr = %AppC{fun: %IdC{s: "/"}, args: [%NumC{n: 10}, %NumC{n: 0}]}
      assert_raise RuntimeError, "SZMX Error: Division by zero", fn ->
        SzmxInterpreter.interp(expr, env)
      end
    end

    test "Less than or equal", %{env: env} do
      expr1 = %AppC{fun: %IdC{s: "<="}, args: [%NumC{n: 1}, %NumC{n: 2}]}
      assert SzmxInterpreter.interp(expr1, env) == %BoolV{b: true}

      expr2 = %AppC{fun: %IdC{s: "<="}, args: [%NumC{n: 2}, %NumC{n: 1}]}
      assert SzmxInterpreter.interp(expr2, env) == %BoolV{b: false}
    end

    test "Equal? numbers", %{env: env} do
      expr = %AppC{fun: %IdC{s: "equal?"}, args: [%NumC{n: 1}, %NumC{n: 1}]}
      assert SzmxInterpreter.interp(expr, env) == %BoolV{b: true}
    end

    test "Equal? strings", %{env: env} do
      expr = %AppC{fun: %IdC{s: "equal?"}, args: [%StrC{s: "foo"}, %StrC{s: "foo"}]}
      assert SzmxInterpreter.interp(expr, env) == %BoolV{b: true}
    end

    test "Equal? primitives returns false", %{env: env} do
      expr = %AppC{fun: %IdC{s: "equal?"}, args: [%IdC{s: "+"}, %IdC{s: "+"}]}
      assert SzmxInterpreter.interp(expr, env) == %BoolV{b: false}
    end

    test "Substring", %{env: env} do
      expr = %AppC{fun: %IdC{s: "substring"}, args: [%StrC{s: "hello"}, %NumC{n: 1}, %NumC{n: 3}]}
      assert SzmxInterpreter.interp(expr, env) == %StrV{s: "el"}
    end

    test "Substring out of bounds", %{env: env} do
      expr = %AppC{fun: %IdC{s: "substring"}, args: [%StrC{s: "hello"}, %NumC{n: 0}, %NumC{n: 10}]}
      assert_raise RuntimeError, "SZMX Error: substring index out of bounds", fn ->
        SzmxInterpreter.interp(expr, env)
      end
    end

    test "Strlen", %{env: env} do
      expr = %AppC{fun: %IdC{s: "strlen"}, args: [%StrC{s: "hello"}]}
      assert SzmxInterpreter.interp(expr, env) == %NumV{n: 5}
    end

    test "User Error", %{env: env} do
      expr = %AppC{fun: %IdC{s: "error"}, args: [%StrC{s: "something went wrong"}]}
      assert_raise RuntimeError, "SZMX Error: user-error \"something went wrong\"", fn ->
        SzmxInterpreter.interp(expr, env)
      end
    end

    test "Invalid arguments for primitive", %{env: env} do
      expr = %AppC{fun: %IdC{s: "+"}, args: [%NumC{n: 1}, %StrC{s: "2"}]}
      assert_raise RuntimeError, "SZMX Error: Invalid arguments for primitive +", fn ->
        SzmxInterpreter.interp(expr, env)
      end
    end
  end
end
