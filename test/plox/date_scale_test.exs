defmodule Plox.DateScaleTest do
  use ExUnit.Case

  alias Plox.DateScale
  alias Plox.Scale

  doctest DateScale

  describe "new/2" do
    test "with a valid Date range" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-03]))
      assert scale.range == Date.range(~D[2019-01-01], ~D[2019-01-03], 1)
    end

    test "with a valid Date range reduces step to 1" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-03], 2))
      assert scale.range == Date.range(~D[2019-01-01], ~D[2019-01-03], 1)
    end

    test "with a valid reverse Date range" do
      scale = DateScale.new(Date.range(~D[2019-01-03], ~D[2019-01-01], -1))
      assert scale.range == Date.range(~D[2019-01-03], ~D[2019-01-01], -1)
    end

    test "raises an error with identical dates" do
      assert_raise ArgumentError, fn ->
        DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-01]))
      end
    end

    test "raises an error with invalid Date range" do
      assert_raise ArgumentError, fn ->
        DateScale.new(0..1)
      end
    end
  end

  describe "values/2" do
    test "with default step (1d) and start" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-03]))
      assert Scale.values(scale) == Date.range(~D[2019-01-01], ~D[2019-01-03], 1)
    end

    test "with positive custom step in days" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-10]))
      assert Scale.values(scale, %{step: 2}) == Date.range(~D[2019-01-01], ~D[2019-01-10], 2)
    end

    test "with negative custom step in days" do
      scale = DateScale.new(Date.range(~D[2019-01-10], ~D[2019-01-01], -1))
      assert Scale.values(scale, %{step: 2}) == Date.range(~D[2019-01-10], ~D[2019-01-01], -2)
    end

    test "raises an error with zero step" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-10]))

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{step: 0})
      end
    end

    test "raises an error with negative step" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-10]))

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{step: -1})
      end
    end

    test "with custom start" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-05]))
      assert Scale.values(scale, %{start: ~D[2019-01-03]}) == Date.range(~D[2019-01-03], ~D[2019-01-05])
    end

    test "raises an error with start before range" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-05]))

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{start: ~D[2018-12-31]})
      end
    end

    test "raises an error with start after range" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-05]))

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{start: ~D[2019-01-06]})
      end
    end

    test "with custom step and start" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-10]))
      assert Scale.values(scale, %{step: 3, start: ~D[2019-01-02]}) == Date.range(~D[2019-01-02], ~D[2019-01-10], 3)
    end
  end

  describe "convert_to_range/3" do
    test "with a valid Date in the range" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-09]))
      assert Scale.convert_to_range(scale, ~D[2019-01-05], 0..100) == 50.0
    end

    test "with a valid Date in the reverse range" do
      scale = DateScale.new(Date.range(~D[2019-01-09], ~D[2019-01-01], -1))
      assert Scale.convert_to_range(scale, ~D[2019-01-07], 0..100) == 25.0
    end

    test "raises an error with Date outside the range" do
      scale = DateScale.new(Date.range(~D[2019-01-01], ~D[2019-01-10]))

      assert_raise ArgumentError, fn ->
        Scale.convert_to_range(scale, ~D[2019-01-12], 0..100)
      end
    end
  end
end
