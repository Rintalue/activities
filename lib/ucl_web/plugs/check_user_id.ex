defmodule UclWeb.CheckUserId do

    import Plug.Conn
    import Phoenix.Controller

    def init(default), do: default

    def call(conn, _opts) do
      user = conn.assigns[:current_user]


      if user && user.id == 6 do
        conn
      else
        conn
        |> put_flash(:error, "Access restricted")
        |> redirect(to: "/user/activities")
        |> halt()
      end
    end
  end
