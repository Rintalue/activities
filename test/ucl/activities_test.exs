defmodule Ucl.ActivitiesTest do
  use Ucl.DataCase

  alias Ucl.Activities

  describe "activities" do
    alias Ucl.Activities.Activity

    import Ucl.ActivitiesFixtures

    @invalid_attrs %{product_batch: nil, start_time: nil, stop_time: nil, type: nil}

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Activities.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Activities.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      valid_attrs = %{product_batch: "some product_batch", start_time: ~N[2024-11-19 11:55:00], stop_time: ~N[2024-11-19 11:55:00], type: "some type"}

      assert {:ok, %Activity{} = activity} = Activities.create_activity(valid_attrs)
      assert activity.product_batch == "some product_batch"
      assert activity.start_time == ~N[2024-11-19 11:55:00]
      assert activity.stop_time == ~N[2024-11-19 11:55:00]
      assert activity.type == "some type"
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      update_attrs = %{product_batch: "some updated product_batch", start_time: ~N[2024-11-20 11:55:00], stop_time: ~N[2024-11-20 11:55:00], type: "some updated type"}

      assert {:ok, %Activity{} = activity} = Activities.update_activity(activity, update_attrs)
      assert activity.product_batch == "some updated product_batch"
      assert activity.start_time == ~N[2024-11-20 11:55:00]
      assert activity.stop_time == ~N[2024-11-20 11:55:00]
      assert activity.type == "some updated type"
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_activity(activity, @invalid_attrs)
      assert activity == Activities.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Activities.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Activities.change_activity(activity)
    end
  end
end
