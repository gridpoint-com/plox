defmodule Plox.YAxisTest do
  use ExUnit.Case

  alias Plox.Axis
  alias Plox.YAxis

  doctest YAxis

  setup do
    %{
      scale: Plox.NumberScale.new(0, 10),
      dimensions: Plox.Dimensions.new(100, 100, margin: 0)
    }
  end

  test "new/2", %{scale: scale, dimensions: dimensions} do
    assert YAxis.new(scale, dimensions) == %YAxis{
             scale: scale,
             dimensions: dimensions
           }
  end

  test "implements to_graph/2", %{scale: scale, dimensions: dimensions} do
    y_axis = YAxis.new(scale, dimensions)

    # y coordinates are height - the expected value (100 - 10 = 90, 100 - 20 = 80)
    assert Axis.Protocol.to_graph(y_axis, 1) == 90.0
    assert Axis.Protocol.to_graph(y_axis, 2) == 80.0
  end

  test "fetches graphable values using Access syntax", %{scale: scale, dimensions: dimensions} do
    y_axis = YAxis.new(scale, dimensions)

    # y coordinates are height - the expected value (100 - 10 = 90, 100 - 20 = 80)
    assert y_axis[1] == 90.0
    assert y_axis[2] == 80.0
  end
end
