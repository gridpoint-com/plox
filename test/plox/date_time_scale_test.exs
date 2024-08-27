defmodule Plox.DateTimeScaleTest do
  use ExUnit.Case

  alias Plox.DateTimeScale

  doctest DateTimeScale

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "new/2" do
    scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])
    assert scale.first == ~N[2019-01-01 00:00:00]
    assert scale.last == ~N[2019-01-03 00:00:00]
  end
end
