defmodule PloxTest do
  use ExUnit.Case

  describe "points/2" do
    test "handles constant values" do
      assert Plox.points(1, 2) == [{1, 2}]
      assert Plox.points([1, 2], [3, 4]) == [{1, 3}, {2, 4}]
    end

    test "handles DatasetAxes" do
      data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      scale = Plox.NumberScale.new(0, 10)

      x_axis = Plox.XAxis.new(scale, dimensions)
      y_axis = Plox.YAxis.new(scale, dimensions)
      axis_fns = %{x: {x_axis, & &1.foo}, y: {y_axis, & &1.bar}}
      dataset = Plox.Dataset.new(data, axis_fns)

      # y coordinates are height - the expected value (100 - 20 = 80, 100 - 30 = 70)
      assert Plox.points(dataset[:x], dataset[:y]) == [{10.0, 80.0}, {20.0, 70.0}]
      assert Plox.points(dataset[:x], 1) == [{10.0, 1.0}, {20.0, 1.0}]
      assert Plox.points(1, dataset[:y]) == [{1.0, 80.0}, {1.0, 70.0}]
      assert Plox.points(dataset[:x], [3, 4]) == [{10.0, 3.0}, {20.0, 4.0}]
      assert Plox.points([1, 2], dataset[:y]) == [{1.0, 80.0}, {2.0, 70.0}]
    end
  end

  describe "values/1" do
    test "handles constant values" do
      assert Plox.values([1, 2]) == [{1, 2}]
      assert Plox.values([[1, 2], [3, 4]]) == [{1, 3}, {2, 4}]
    end

    test "handles DatasetAxes" do
      data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      scale = Plox.NumberScale.new(0, 10)

      x_axis = Plox.XAxis.new(scale, dimensions)
      y_axis = Plox.YAxis.new(scale, dimensions)
      axis_fns = %{x: {x_axis, & &1.foo}, y: {y_axis, & &1.bar}}
      dataset = Plox.Dataset.new(data, axis_fns)

      # y coordinates are height - the expected value (100 - 20 = 80, 100 - 30 = 70)
      assert Plox.values([dataset[:x], dataset[:y]]) == [{10.0, 80.0}, {20.0, 70.0}]
      assert Plox.values([dataset[:x], 1]) == [{10.0, 1.0}, {20.0, 1.0}]
      assert Plox.values([1, dataset[:y]]) == [{1.0, 80.0}, {1.0, 70.0}]
      assert Plox.values([dataset[:x], [3, 4]]) == [{10.0, 3.0}, {20.0, 4.0}]
      assert Plox.values([[1, 2], dataset[:y]]) == [{1.0, 80.0}, {2.0, 70.0}]
    end
  end

  describe "scale_values/2" do
    test "delegates to Scale.values/2 with no options" do
      scale = Plox.NumberScale.new(0, 10)
      axis = Plox.XAxis.new(scale, Plox.Dimensions.new(100, 100))

      assert Plox.scale_values(axis) == Plox.Scale.values(scale)
    end

    test "delegates to Scale.values/2 with ticks" do
      scale = Plox.NumberScale.new(0, 10)
      axis = Plox.XAxis.new(scale, Plox.Dimensions.new(100, 100))

      assert Plox.scale_values(axis, %{ticks: 5}) == Plox.Scale.values(scale, %{ticks: 5})
    end

    test "delegates to Scale.values/2 with step" do
      scale = Plox.DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-10]))
      axis = Plox.XAxis.new(scale, Plox.Dimensions.new(100, 100))

      assert Plox.scale_values(axis, %{step: 2}) == Plox.Scale.values(scale, %{step: 2})
    end

    test "delegates to Scale.values/2 with step tuple" do
      scale = Plox.DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:10:00])
      axis = Plox.XAxis.new(scale, Plox.Dimensions.new(100, 100))

      assert Plox.scale_values(axis, %{step: {2, :minute}}) ==
               Plox.Scale.values(scale, %{step: {2, :minute}})
    end

    test "delegates to Scale.values/2 with start" do
      scale = Plox.DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])
      axis = Plox.XAxis.new(scale, Plox.Dimensions.new(100, 100))

      assert Plox.scale_values(axis, %{start: ~N[2019-01-01 00:01:00]}) ==
               Plox.Scale.values(scale, %{start: ~N[2019-01-01 00:01:00]})
    end
  end
end
