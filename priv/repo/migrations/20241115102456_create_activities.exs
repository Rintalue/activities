defmodule Ucl.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :type, :string
      add :start_time, :naive_datetime
      add :stop_time, :naive_datetime
      add :product_batch, :string
      add :room_id, references(:rooms, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:activities, [:room_id])
    create index(:activities, [:user_id])
  end
end
