defmodule Ucl.Repo do
  use Ecto.Repo,
    otp_app: :ucl,
    adapter: Ecto.Adapters.MyXQL
end
