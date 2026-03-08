defmodule SzmxInterpreter do
  @moduledoc """
  SZMX4 Interpreter in Elixir
  """

  # --- Data Definitions (AST Nodes) ---
  defmodule NumC, do: defstruct [:n]
  defmodule IdC,  do: defstruct [:s]
  defmodule StrC, do: defstruct [:s]
  defmodule IfC,  do: defstruct [:test, :then, :else]
  defmodule AppC, do: defstruct [:fun, :args]
  defmodule LamC, do: defstruct [:params, :body]

  # --- Values ---
  defmodule NumV,   do: defstruct [:n]
  defmodule BoolV,  do: defstruct [:b]
  defmodule StrV,   do: defstruct [:s]
  defmodule CloV, do: defstruct [:params, :body, :env]
  defmodule PrimV,  do: defstruct [:op_symbol]

  # --- Types for typing system ---
  @type expression :: %NumC{} | %IdC{} | %StrC{} | %IfC{} | %AppC{} | %LamC{}
  @type value :: %NumV{} | %BoolV{} | %StrV{} | %CloV{} | %PrimV{}
  @type env :: %{String.t() => value()}

  @doc "Top-level environment with primitives and constants"
  @spec top_env() :: env()
  def top_env do
    %{
      "true" => %BoolV{b: true},
      "false" => %BoolV{b: false},
      "+" => %PrimV{op_symbol: "+"},
      "-" => %PrimV{op_symbol: "-"},
      "*" => %PrimV{op_symbol: "*"},
      "/" => %PrimV{op_symbol: "/"},
      "<=" => %PrimV{op_symbol: "<="},
      "equal?" => %PrimV{op_symbol: "equal?"},
      "substring" => %PrimV{op_symbol: "substring"},
      "strlen" => %PrimV{op_symbol: "strlen"},
      "error" => %PrimV{op_symbol: "error"}
    }
  end

  # --- HELPER FUNCTIONS ---
  @doc "Given an operator and a list of arguments, apply the primitive operation to the list of arguments."
  @spec apply_prim(String.t(), [value()]) :: value()
  def apply_prim(op, args) do
    case {op, args} do
      {"+", [%NumV{n: n1}, %NumV{n: n2}]} -> %NumV{n: n1 + n2}
      {"-", [%NumV{n: n1}, %NumV{n: n2}]} -> %NumV{n: n1 - n2}
      {"*", [%NumV{n: n1}, %NumV{n: n2}]} -> %NumV{n: n1 * n2}
      {"/", [%NumV{n: n1}, %NumV{n: n2}]} ->
        if n2 == 0, do: raise("SZMX Error: Division by zero"), else: %NumV{n: n1 / n2}

      {"<=", [%NumV{n: n1}, %NumV{n: n2}]} -> %BoolV{b: n1 <= n2}

      {"equal?", [v1, v2]} ->
        # returns false for functions/primitives, true/false for values
        case {v1, v2} do
          {%CloV{}, _} -> %BoolV{b: false}
          {_, %CloV{}} -> %BoolV{b: false}
          {%PrimV{}, _} -> %BoolV{b: false}
          {_, %PrimV{}} -> %BoolV{b: false}
          _ -> %BoolV{b: v1 == v2}
        end

      {"substring", [%StrV{s: s}, %NumV{n: start}, %NumV{n: stop}]} ->
        len = String.length(s)
        start_int = trunc(start)
        stop_int = trunc(stop)

        if start_int < 0 or stop_int < 0 or stop_int > len or start_int > stop_int do
           raise "SZMX Error: substring index out of bounds"
        end
        %StrV{s: String.slice(s, start_int, stop_int - start_int)}

      {"strlen", [%StrV{s: s}]} -> %NumV{n: String.length(s)}

      {"error", [val]} -> raise "SZMX Error: user-error #{serialize(val)}"

      _ -> raise "SZMX Error: Invalid arguments for primitive #{op}"
    end
  end


  # --- CORE FUNCTIONS ---
  @doc "Given a expression and an environment, interperet the expression and return a value."
  @spec interp(expression(), env()) :: value()
  def interp(expr, env) do
    case expr do
      %NumC{n: n} -> %NumV{n: n}
      %StrC{s: s} -> %StrV{s: s}
      %IdC{s: s}  ->
        case Map.fetch(env, s) do
          {:ok, val} -> val
          :error -> raise "SZMX Error: Variable #{s} not found in environment"
        end

      %IfC{test: test, then: then, else: el} ->
        case interp(test, env) do
          %BoolV{b: true} -> interp(then, env)
          %BoolV{b: false} -> interp(el, env)
          _ -> raise "SZMX Error: If test must evaluate to a boolean"
        end

      %LamC{params: params, body: body} ->
        %CloV{params: params, body: body, env: env}

      %AppC{fun: fun_expr, args: args_exprs} ->
        f_val = interp(fun_expr, env)
        arg_vals = Enum.map(args_exprs, fn arg -> interp(arg, env) end)

        case f_val do
          %CloV{params: params, body: body, env: c_env} ->
            if length(params) != length(arg_vals), do: raise("SZMX Error: Mismatch between number of arguments and parameters")
            new_env = Enum.zip(params, arg_vals) |> Enum.into(c_env)
            interp(body, new_env)

          %PrimV{op_symbol: op} ->
            apply_prim(op, arg_vals)

          _ -> raise "SZMX Error: Application of non-function"
        end
    end
  end

  @doc "Given a value, return a string representation of it."
  @spec serialize(value()) :: String.t()
  def serialize(val) do
    case val do
      %NumV{n: n} -> "#{n}"
      %StrV{s: s} -> "\"#{s}\""
      %BoolV{b: b} -> "#{b}"
      %CloV{} -> "#<procedure>"
      %PrimV{} -> "#<primop>"
      _ -> raise "SZMX Error: Unknown value type"
    end
  end
end
