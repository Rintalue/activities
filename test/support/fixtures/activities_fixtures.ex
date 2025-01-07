defmodule Ucl.ActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ucl.Activities` context.
  """

  @doc """
  Generate a activity.
  """
  def activity_fixture(attrs \\ %{}) do
    {:ok, activity} =
      attrs
      |> Enum.into(%{
        batch_number: "some product_batch",
        start_time: ~N[2024-11-19 11:55:00],
        stop_time: ~N[2024-11-19 11:55:00],
        type: "some type"
      })
      |> Ucl.Activities.Activities.create_activity()

    activity
  end
end
