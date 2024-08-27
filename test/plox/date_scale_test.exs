defmodule Plox.DateScaleTest do
  use ExUnit.Case

  alias Plox.DateScale

  doctest DateScale

  test "new/2" do
    scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-03]))
    assert scale.range == Date.range(~D[2019-01-01], ~D[2019-01-03])
  end

  test "new/2 given a range with a step it reduces it to 1" do
    scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-03], 2))
    assert scale.range == Date.range(~D[2019-01-01], ~D[2019-01-03])
  end
end
