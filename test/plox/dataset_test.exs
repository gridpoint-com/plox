defmodule Plox.DatasetTest do
  use ExUnit.Case

  alias Plox.DataPoint
  alias Plox.Dataset
  alias Plox.DatasetAxis

  describe "DatasetAxis" do
    test "fetch/2 returns graphable coordinates" do
      data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      scale = Plox.NumberScale.new(0, 10)

      x_axis = Plox.XAxis.new(scale, dimensions)
      y_axis = Plox.YAxis.new(scale, dimensions)
      axis_fns = %{x: {x_axis, & &1.foo}, y: {y_axis, & &1.bar}}
      dataset = Dataset.new(data, axis_fns)

      assert {:ok, dataset_axis_x} = Dataset.fetch(dataset, :x)
      assert {:ok, dataset_axis_y} = Dataset.fetch(dataset, :y)

      # y coordinates are height - the expected value (100 - 20 = 80, 100 - 30 = 70)
      assert {:ok, 10.0} = DatasetAxis.fetch(dataset_axis_x, 1)
      assert {:ok, 20.0} = DatasetAxis.fetch(dataset_axis_x, 2)
      assert {:ok, 80.0} = DatasetAxis.fetch(dataset_axis_y, 2)
      assert {:ok, 70.0} = DatasetAxis.fetch(dataset_axis_y, 3)
    end

    test "fetches graphable coordinates using Access syntax" do
      data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      scale = Plox.NumberScale.new(0, 10)

      x_axis = Plox.XAxis.new(scale, dimensions)
      y_axis = Plox.YAxis.new(scale, dimensions)
      axis_fns = %{x: {x_axis, & &1.foo}, y: {y_axis, & &1.bar}}
      dataset = Dataset.new(data, axis_fns)

      # y coordinates are height - the expected value (100 - 20 = 80, 100 - 30 = 70)
      assert 10.0 = dataset[:x][1]
      assert 20.0 = dataset[:x][2]
      assert 80.0 = dataset[:y][2]
      assert 70.0 = dataset[:y][3]
    end
  end

  describe "Dataset" do
    test "new/2" do
      data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      scale = Plox.NumberScale.new(0, 10)

      x_axis = Plox.XAxis.new(scale, dimensions)
      y_axis = Plox.YAxis.new(scale, dimensions)
      axis_fns = %{x: {x_axis, & &1.foo}, y: {y_axis, & &1.bar}}
      dataset = Dataset.new(data, axis_fns)

      assert dataset.axes == %{x: x_axis, y: y_axis}

      # y coordinates are height - the expected value (100 - 20 = 80, 100 - 30 = 70)
      assert dataset.data == [
               %DataPoint{original: %{foo: 1, bar: 2}, graph: %{x: 10.0, y: 80.0}},
               %DataPoint{original: %{foo: 2, bar: 3}, graph: %{x: 20.0, y: 70.0}}
             ]
    end

    test "fetch/2 returns DatasetAxes" do
      data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      scale = Plox.NumberScale.new(0, 10)

      x_axis = Plox.XAxis.new(scale, dimensions)
      y_axis = Plox.YAxis.new(scale, dimensions)
      axis_fns = %{x: {x_axis, & &1.foo}, y: {y_axis, & &1.bar}}
      dataset = Dataset.new(data, axis_fns)

      assert {:ok, %DatasetAxis{axis: ^x_axis}} = Dataset.fetch(dataset, :x)
      assert {:ok, %DatasetAxis{axis: ^y_axis}} = Dataset.fetch(dataset, :y)
      assert Dataset.fetch(dataset, :z) == :error
    end

    test "fetches DatasetAxes using Access syntax" do
      data = [%{foo: 1, bar: 2}, %{foo: 2, bar: 3}]
      dimensions = Plox.Dimensions.new(100, 100, margin: 0)
      scale = Plox.NumberScale.new(0, 10)

      x_axis = Plox.XAxis.new(scale, dimensions)
      y_axis = Plox.YAxis.new(scale, dimensions)
      axis_fns = %{x: {x_axis, & &1.foo}, y: {y_axis, & &1.bar}}
      dataset = Dataset.new(data, axis_fns)

      assert %DatasetAxis{axis: ^x_axis} = dataset[:x]
      assert %DatasetAxis{axis: ^y_axis} = dataset[:y]
      assert dataset[:z] == nil
    end
  end
end
