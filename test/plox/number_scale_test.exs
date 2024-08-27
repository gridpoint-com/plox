defmodule Plox.NumberScaleTest do
  use ExUnit.Case

  doctest Plox.NumberScale

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "scale" do
    scale = Plox.NumberScale.new(0, 100)
    Plox.Scale.convert_to_range(scale, 200, 0..1000)
  end
end
