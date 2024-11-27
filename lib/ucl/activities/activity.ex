defmodule Ucl.Activities.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :product_batch, :string
    field :start_time, :naive_datetime
    field :stop_time, :naive_datetime
    field :type, :string
    field :room_id, :id


    belongs_to :user, Ucl.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:type, :start_time, :stop_time, :product_batch, :room_id, :user_id])
    |> validate_required([:type, :start_time, :product_batch])
  end
end
