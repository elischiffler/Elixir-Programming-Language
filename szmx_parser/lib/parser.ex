defmodule PARSER do
  @moduledoc """
  Documentation for `PARSER`.
  """
  SzmxInter
  @spec parser(String.t()) :: SzmxInterpreter.expression()
  def parser(src) when is_binary(src) do
    chars = String.to_charlist(src)

    case :lexer.string(chars) do
      {:ok, toks, line} ->
        case :parser.parse(toks ++ [{:"$end", line}]) do
          {:ok, ast} ->
            ast

          {:error, err} ->
            raise "SZMX Error: parse error #{inspect(err)}"
        end

      {:error, err, _line} ->
        raise "SZMX Error: lex error #{inspect(err)}"
    end
  end
end
