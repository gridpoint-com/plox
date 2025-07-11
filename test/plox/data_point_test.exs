defmodule Plox.DataPointTest do
  use ExUnit.Case

  alias Plox.DataPoint

  doctest DataPoint

  test "new/3" do
    data_point = DataPoint.new(%{foo: 1, bar: 2}, %{x: 1, y: 2})
    assert data_point.original == %{foo: 1, bar: 2}
    assert data_point.graph == %{x: 1, y: 2}
  end
end
