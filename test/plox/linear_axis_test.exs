defmodule Plox.LinearAxisTest do
  use ExUnit.Case

  alias Plox.Axis
  alias Plox.LinearAxis

  doctest LinearAxis

  setup do
    %{scale: Plox.NumberScale.new(0, 10)}
  end

  test "new/2", %{scale: scale} do
    assert LinearAxis.new(scale, min: 0, max: 100) == %LinearAxis{
             scale: scale,
             min: 0,
             max: 100
           }
  end

  test "implements to_graph/2", %{scale: scale} do
    linear_axis = LinearAxis.new(scale, min: 0, max: 100)

    assert Axis.Protocol.to_graph(linear_axis, 1) == 10.0
    assert Axis.Protocol.to_graph(linear_axis, 2) == 20.0
  end

  test "fetches graphable values using Access syntax", %{scale: scale} do
    linear_axis = LinearAxis.new(scale, min: 0, max: 100)

    assert linear_axis[1] == 10.0
    assert linear_axis[2] == 20.0
  end
end
