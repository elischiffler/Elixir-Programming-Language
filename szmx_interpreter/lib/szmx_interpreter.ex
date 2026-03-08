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
  defmodule CloV, do: defstruct [:params, :body, :env]
  defmodule PrimV,  do: defstruct [:op_symbol]

  @doc "The core interpreter function"
  def interp(expr, env) do
    case expr do
      %NumC{n: n} -> n
      %StrC{s: s} -> s
      %IdC{s: s}  -> Map.get(env, s) || raise "SZMX Error: Variable #{s} not found"

      %IfC{test: test, then: then, else: el} ->
        if interp(test, env) == true do
          interp(then, env)
        else
          interp(el, env)
        end
    end
  end

  @doc "Serialize values to strings for the assignment requirements"
  def serialize(val) do
    case val do
      v when is_number(v) -> "#{v}"
      v when is_binary(v) -> "\"#{v}\""
      true -> "true"
      false -> "false"
      %CloV{} -> "#<procedure>"
      %PrimV{} -> "#<primop>"
      _ -> raise "SZMX Error: Unknown value type"
    end
  end
end
