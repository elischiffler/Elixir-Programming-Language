defmodule SzmxTest do
  use ExUnit.Case
  doctest Szmx

  # --- Basic functionality test cases ---
  test "topinterp a num" do
    assert Szmx.topinterp("3") == "3.0"
  end

  test "topinterp a str" do
    assert Szmx.topinterp("\"Hello World\"") == "\"Hello World\""
  end

  test "topinterp a boolean" do
    assert Szmx.topinterp("true") == "true"
  end

  test "topinterp a function application" do
    assert Szmx.topinterp("{+ 2 3}") == "5.0"
  end

  test "topinterp a procedure" do
    assert Szmx.topinterp("{fun (x y) => (1)}") == "#<procedure>"
  end

  test "topinterp a primitive operator" do
    assert Szmx.topinterp("{if false + -}") == "#<primop>"
  end


  # --- Larger test cases ---

  test "topinterp function application of another function" do
    assert Szmx.topinterp("{{fun {minus} => {minus 8 5}} {fun {a b} => {+ a {* -1 b}}}}")
     == "3.0"
  end


end
