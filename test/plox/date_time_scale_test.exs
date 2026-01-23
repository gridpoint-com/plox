defmodule Plox.DateTimeScaleTest do
  use ExUnit.Case

  alias Plox.DateTimeScale
  alias Plox.Scale

  doctest DateTimeScale

  describe "new/2" do
    test "with valid NaiveDateTimes" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])
      assert scale.first == ~N[2019-01-01 00:00:00]
      assert scale.last == ~N[2019-01-03 00:00:00]
    end

    test "with valid DateTimes" do
      scale = DateTimeScale.new(~U[2019-01-01 00:00:00Z], ~U[2019-01-03 00:00:00Z])
      assert scale.first == ~U[2019-01-01 00:00:00Z]
      assert scale.last == ~U[2019-01-03 00:00:00Z]
    end

    test "raises an error with identical DateTimes" do
      assert_raise ArgumentError, fn ->
        DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:00:00])
      end
    end

    test "raises an error with identical NaiveDateTimes" do
      assert_raise ArgumentError, fn ->
        DateTimeScale.new(~U[2019-01-01 00:00:00Z], ~U[2019-01-01 00:00:00Z])
      end
    end

    test "raises an error with mixed structs" do
      assert_raise ArgumentError, fn ->
        DateTimeScale.new(~N[2019-01-01 00:00:00], ~U[2019-01-03 00:00:00Z])
      end
    end

    test "raises an error with negative ranges" do
      assert_raise ArgumentError, fn ->
        DateTimeScale.new(~N[2019-01-03 00:00:00], ~N[2019-01-01 00:00:00])
      end
    end
  end

  describe "values/2" do
    test "with default step (60s)" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert Scale.values(scale) == [
               ~N[2019-01-01 00:00:00],
               ~N[2019-01-01 00:01:00],
               ~N[2019-01-01 00:02:00]
             ]
    end

    test "with valid step in days" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])

      assert Scale.values(scale, %{step: {1, :day}}) == [
               ~N[2019-01-01 00:00:00],
               ~N[2019-01-02 00:00:00],
               ~N[2019-01-03 00:00:00]
             ]
    end

    test "with valid step in hours" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 01:00:00])

      assert Scale.values(scale, %{step: {1, :hour}}) == [
               ~N[2019-01-01 00:00:00],
               ~N[2019-01-01 01:00:00]
             ]
    end

    test "with valid step in minutes" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert Scale.values(scale, %{step: {1, :minute}}) == [
               ~N[2019-01-01 00:00:00],
               ~N[2019-01-01 00:01:00],
               ~N[2019-01-01 00:02:00]
             ]
    end

    test "with valid step in seconds" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:00:03])

      assert Scale.values(scale, %{step: {1, :second}}) == [
               ~N[2019-01-01 00:00:00],
               ~N[2019-01-01 00:00:01],
               ~N[2019-01-01 00:00:02],
               ~N[2019-01-01 00:00:03]
             ]
    end

    test "raises an error with zero step" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{step: 0})
      end
    end

    test "raises an error with invalid step" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{step: {-500, :invalid}})
      end
    end

    test "with default start" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert Scale.values(scale) == [
               ~N[2019-01-01 00:00:00],
               ~N[2019-01-01 00:01:00],
               ~N[2019-01-01 00:02:00]
             ]
    end

    test "with custom start" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert Scale.values(scale, %{start: ~N[2019-01-01 00:01:00]}) == [
               ~N[2019-01-01 00:01:00],
               ~N[2019-01-01 00:02:00]
             ]
    end

    test "raises an error with start before range" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{start: ~N[2018-12-31 23:59:59]})
      end
    end

    test "raises an error with start after range" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-01 00:02:00])

      assert_raise ArgumentError, fn ->
        Scale.values(scale, %{start: ~N[2019-01-01 00:03:00]})
      end
    end
  end

  describe "convert_to_range/3" do
    test "with valid NaiveDateTime" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])
      assert Scale.convert_to_range(scale, ~N[2019-01-02 00:00:00], 0..100) == 50.0
    end

    test "with valid DateTime" do
      scale = DateTimeScale.new(~U[2019-01-01 00:00:00Z], ~U[2019-01-03 00:00:00Z])
      assert Scale.convert_to_range(scale, ~U[2019-01-02 00:00:00Z], 0..100) == 50.0
    end

    test "raises an error with values outside the scale" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])

      assert_raise ArgumentError, fn ->
        Scale.convert_to_range(scale, ~N[2019-01-04 00:00:00], 0..100)
      end
    end

    test "raises an error with invalid datetime" do
      scale = DateTimeScale.new(~N[2019-01-01 00:00:00], ~N[2019-01-03 00:00:00])

      assert_raise ArgumentError, fn ->
        Scale.convert_to_range(scale, ~U[2019-01-02 12:00:00Z], 0..100)
      end
    end
  end
end
