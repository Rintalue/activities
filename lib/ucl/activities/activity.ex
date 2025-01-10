defmodule Ucl.Activities.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :batch_number, :string
    field :product_id, :string
    field :product_description, :string
    field :duration, :integer
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
    |> cast(attrs, [:type, :start_time, :stop_time, :batch_number, :product_id, :product_description, :room_id, :user_id, :duration])
    |> validate_required([:type, :start_time])
  end
end
