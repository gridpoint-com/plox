defmodule Plox.DateTimeScaleTest do
  use ExUnit.Case, async: true

  alias Plox.DateTimeScale
  alias Plox.Scale

  describe "new/2" do
    test "creates a scale from DateTime structs" do
      assert %DateTimeScale{} =
               DateTimeScale.new(~U[2023-03-12 09:00:00Z], ~U[2023-03-12 11:00:00Z])
    end

    test "creates a scale from NaiveDateTime structs" do
      assert %DateTimeScale{} =
               DateTimeScale.new(~N[2023-03-12 09:00:00], ~N[2023-03-12 11:00:00])
    end

    test "raises if the start and end times are the same" do
      assert_raise(ArgumentError, fn ->
        DateTimeScale.new(~N[2023-03-12 09:00:00], ~N[2023-03-12 09:00:00])
      end)
    end

    test "raises if the start time is before the end time" do
      assert_raise(ArgumentError, fn ->
        DateTimeScale.new(~N[2023-03-12 09:00:01], ~N[2023-03-12 09:00:00])
      end)
    end

    test "raises if the types don't match" do
      assert_raise(ArgumentError, fn ->
        DateTimeScale.new(~N[2023-03-12 09:00:00], ~U[2023-03-12 11:00:00Z])
      end)
    end
  end

  describe "implementation: Scale.values/1" do
    test "returns an ordered list of values representing the times to be labeled" do
      scale = DateTimeScale.new(~N[2023-03-12 09:00:00], ~N[2023-03-12 11:00:00])
      step_in_minutes = 30 * 60

      assert [
               ~N[2023-03-12 09:00:00],
               ~N[2023-03-12 09:30:00],
               ~N[2023-03-12 10:00:00],
               ~N[2023-03-12 10:30:00],
               ~N[2023-03-12 11:00:00]
             ] = Scale.values(scale, %{step: step_in_minutes})
    end

    test "might not necessarily contain the last value in the given range" do
      scale = DateTimeScale.new(~N[2023-08-01 00:00:00], ~N[2023-08-04 23:59:59])
      step_in_minutes = 24 * 60 * 60

      assert [
               ~N[2023-08-01 00:00:00],
               ~N[2023-08-02 00:00:00],
               ~N[2023-08-03 00:00:00],
               ~N[2023-08-04 00:00:00]
             ] = Scale.values(scale, %{step: step_in_minutes})
    end

    # test "returns values spanning the start of Daylight Savings Time in hours" do
    #   # `start_dt` is getting an argument error:
    #   # ** (ArgumentError) cannot build datetime with ~D[2023-03-11] and ~T[23:00:00],
    #   # reason: :utc_only_time_zone_database
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-03-11], ~T[23:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-03-12], ~T[03:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt)
    #   # scale = DateTimeScale.new(start_dt, end_dt, 1, :hour)
    #   step_in_minutes = 60 * 60

    #   # expected to skip 2am PST since we "spring forward" to 3am at 2am
    #   expected_utc_values = [
    #     # 11pm PST
    #     ~U[2023-03-12 07:00:00Z],
    #     # 12am PST
    #     ~U[2023-03-12 08:00:00Z],
    #     # 1am PST
    #     ~U[2023-03-12 09:00:00Z],
    #     # 3am PDT
    #     ~U[2023-03-12 10:00:00Z]
    #   ]

    #   test_values = Scale.values(scale, %{step: step_in_minutes})

    #   assert Enum.map(expected_utc_values, &DateTime.shift_zone!(&1, timezone)) ==
    #            test_values
    # end

    # test "returns values spanning the start of Daylight Savings Time in days" do
    #   # `start_dt` is getting an argument error:
    #   # ** (ArgumentError) cannot build datetime with ~D[2023-03-11] and ~T[00:00:00],
    #   # reason: :utc_only_time_zone_database
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-03-11], ~T[00:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-03-14], ~T[00:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt)
    #   # scale = DateTimeScale.new(start_dt, end_dt, 1, :day)
    #   step_in_minutes = 24 * 60 * 60

    #   expected_utc_values = [
    #     # 12am PST
    #     ~U[2023-03-11 08:00:00Z],
    #     ~U[2023-03-12 08:00:00Z],
    #     # 12am PDT
    #     ~U[2023-03-13 07:00:00Z],
    #     ~U[2023-03-14 07:00:00Z]
    #   ]

    #   test_values = Scale.values(scale, %{step: step_in_minutes})

    #   assert Enum.map(expected_utc_values, &DateTime.shift_zone!(&1, timezone)) == test_values
    # end

    # test "returns values spanning the end of Daylight Savings Time in hours" do
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-11-04], ~T[23:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-11-05], ~T[03:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt, 1, :hour)

    #   # expected to repeat 1am since we "fall back" to 1am at 2am
    #   expected_utc_values = [
    #     # 11pm PDT
    #     ~U[2023-11-05 06:00:00Z],
    #     # 12am PDT
    #     ~U[2023-11-05 07:00:00Z],
    #     # 1am PDT
    #     ~U[2023-11-05 08:00:00Z],
    #     # 1am PST
    #     ~U[2023-11-05 09:00:00Z],
    #     # 2am PST
    #     ~U[2023-11-05 10:00:00Z],
    #     # 3am PST
    #     ~U[2023-11-05 11:00:00Z]
    #   ]

    #   test_values = Scale.values(scale)

    #   assert Enum.map(expected_utc_values, &DateTime.shift_zone!(&1, timezone)) ==
    #            test_values
    # end

    # test "returns values spanning the end of Daylight Savings Time in days" do
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-11-04], ~T[00:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-11-07], ~T[00:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt, 1, :day)

    #   expected_utc_values = [
    #     # 12am PDT
    #     ~U[2023-11-04 07:00:00Z],
    #     ~U[2023-11-05 07:00:00Z],
    #     # 12am PST
    #     ~U[2023-11-06 08:00:00Z],
    #     ~U[2023-11-07 08:00:00Z]
    #   ]

    #   test_values = Scale.values(scale)

    #   assert Enum.map(expected_utc_values, &DateTime.shift_zone!(&1, timezone)) == test_values
    # end

    # test "raises if given a range + step combination that would generate invalid DateTime values" do
    #   # `start_dt` is getting an argument error:
    #   # ** (ArgumentError) cannot build datetime with ~D[2023-03-11] and ~T[02:00:00],
    #   # reason: :utc_only_time_zone_database
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-03-11], ~T[02:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-03-14], ~T[02:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt)
    #   # scale = DateTimeScale.new(start_dt, end_dt, 1, :day)
    #   step_in_minutes = 24 * 60 * 60

    #   # 2am doesn't exist on the 12th in this timezone:
    #   assert_raise(ArgumentError, fn ->
    #     Scale.values(scale, %{step: step_in_minutes})
    #   end)
    # end
  end

  describe "implementation: Scale.convert_to_range/3" do
    test "returns a number" do
      scale = DateTimeScale.new(~N[2023-03-12 09:00:00], ~N[2023-03-12 11:00:00])

      assert 25.0 = Scale.convert_to_range(scale, ~N[2023-03-12 09:30:00], 0..100)
    end

    test "raises if given a value outside the range" do
      scale = DateTimeScale.new(~N[2023-03-12 09:00:00], ~N[2023-03-12 11:00:00])

      assert_raise(ArgumentError, fn ->
        Scale.convert_to_range(scale, ~N[2023-03-12 11:00:01], 0..100)
      end)
    end

    test "raises if given a non-matching type" do
      scale = DateTimeScale.new(~N[2023-03-12 09:00:00], ~N[2023-03-12 11:00:00])

      assert_raise(ArgumentError, fn ->
        Scale.convert_to_range(scale, ~U[2023-03-12 09:30:00Z], 0..100)
      end)
    end

    # test "returns correct number for scale spanning the start of Daylight Savings Time in hours" do
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-03-11], ~T[23:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-03-12], ~T[04:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt, 1, :hour)

    #   # 4/5 values between `start_dt` and `end_dt`
    #   value = DateTime.shift_zone!(~U[2023-03-12 10:00:00Z], timezone)

    #   # 4/5 = 75.0 since [0.0, 25.0, 50.0, 75.0, 100.0]
    #   assert 75.0 = Scale.convert_to_range(scale, value, 0..100)
    # end

    # test "returns correct number for scale spanning the start of Daylight Savings Time in days" do
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-03-11], ~T[00:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-03-15], ~T[00:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt, 1, :day)

    #   # 2/5 values between `start_dt` and `end_dt`
    #   # This is "off by 15 minutes" because of the missing hour on the 12th
    #   # 25% will be off by 15 minutes, 50% will be off by half an hour, 75% will
    #   # be off by 45 minutes.
    #   value = DateTime.shift_zone!(~U[2023-03-12 07:45:00Z], timezone)

    #   # 2/5 = 25.0 since [0.0, 25.0, 50.0, 75.0, 100.0]
    #   assert 25.0 = Scale.convert_to_range(scale, value, 0..100)
    # end

    # test "returns correct number for scale spanning the end of Daylight Savings Time in hours" do
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-11-04], ~T[23:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-11-05], ~T[02:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt, 1, :hour)

    #   # 4/5 values between `start_dt` and `end_dt`
    #   value = DateTime.shift_zone!(~U[2023-11-05 09:00:00Z], timezone)

    #   # 4/5 = 75.0 since [0.0, 25.0, 50.0, 75.0, 100.0]
    #   assert 75.0 = Scale.convert_to_range(scale, value, 0..100)
    # end

    # test "returns correct number for scale spanning the end of Daylight Savings Time in days" do
    #   timezone = "America/Los_Angeles"
    #   start_dt = DateTime.new!(~D[2023-11-04], ~T[00:00:00], timezone)
    #   end_dt = DateTime.new!(~D[2023-11-08], ~T[00:00:00], timezone)
    #   scale = DateTimeScale.new(start_dt, end_dt, 1, :day)

    #   # 3/5 values between `start_dt` and `end_dt`
    #   # This is "off by half an hour" because there's an extra hour on the 5th
    #   # 25% will be off by 15 minutes, 50% will be off by half an hour, 75% will
    #   # be off by 45 minutes.
    #   value = DateTime.shift_zone!(~U[2023-11-06 07:30:00Z], timezone)

    #   # 3/5 = 50.0 since [0.0, 25.0, 50.0, 75.0, 100.0]
    #   assert 50.0 = Scale.convert_to_range(scale, value, 0..100)
    # end
  end
end
