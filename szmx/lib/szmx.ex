defmodule Szmx do
  @moduledoc """
  Documentation for `Szmx`.
  """

  @spec topinterp(String.t()) :: String.t()
  def topinterp(input) do
    input
    |> PARSER.parser()
    |> SzmxInterpreter.interp(SzmxInterpreter.top_env())
    |> SzmxInterpreter.serialize()
  end
end
