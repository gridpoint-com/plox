defmodule Plox.DataPointTest do
  use ExUnit.Case

  alias Plox.DataPoint

  doctest DataPoint

  test "new/3" do
    data_point = DataPoint.new(1, %{foo: 1, bar: 2}, %{x: 1, y: 2})
    assert data_point.id == 1
    assert data_point.original == %{foo: 1, bar: 2}
    assert data_point.mapped == %{x: 1, y: 2}
  end
end
