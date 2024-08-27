defmodule Plox.DimensionsTest do
  use ExUnit.Case

  alias Plox.Box
  alias Plox.Dimensions

  doctest Dimensions

  test "new/1" do
    assert Dimensions.new(%{width: 100, height: 100, margin: 0, padding: 0}) == %Dimensions{
             width: 100,
             height: 100,
             margin: %Box{top: 0, right: 0, bottom: 0, left: 0},
             padding: %Box{top: 0, right: 0, bottom: 0, left: 0}
           }
  end
end
