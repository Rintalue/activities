defmodule UclWeb.UserAuthController do
  use UclWeb, :controller

  alias Ucl.Accounts
  alias UclWeb.UserAuth

  def new(conn, %{"room_id" => room_id, "type_selected" => type_selected, "sub_type_selected" => sub_type_selected}) do
    render(conn, "new.html", room_id: room_id, type_selected: type_selected, sub_type_selected: sub_type_selected)
  end


  def log_in(conn, %{"user" => user_params}) do
    case Accounts.get_user_by_email_and_password(user_params["emp_id"], user_params["password"]) do
      nil ->
        conn
        |> put_flash(:error, "Invalid employee ID or password")
        |> redirect(to: "/login")

      user ->
        # Store parameters in session for continuity
        conn
        |> put_session(:room_id, user_params["room_id"])
        |> put_session(:type_selected, user_params["type_selected"])
        |> put_session(:sub_type_selected, user_params["sub_type_selected"])
        |> put_flash(:info, "Welcome back!")
        |> UserAuth.log_in_user(user)
        |> redirect(to: "/user/activities/new")  # You can use a simple redirect to the next page if not in LiveView
    end
  end
  def create(conn, %{"user" => %{"emp_id" => emp_id, "password" => password}}) do
    case Accounts.get_user_by_email_and_password(emp_id, password) do
      nil ->
        conn
        |> put_flash(:error, "Invalid employee ID or password")
        |> redirect(to: ~p"/users/log_in")

      user ->
        # Store session data for continuity across requests
        room_id = get_session(conn, :room_id)
        type_selected = get_session(conn, :type_selected)
        sub_type_selected = get_session(conn, :sub_type_selected)

        conn
        |> put_flash(:info, "Login successful!")
        |> redirect(to: Routes.user_activities_path(conn, :new,
              room_id: room_id,
              type_selected: type_selected,
              sub_type_selected: sub_type_selected))
    end
  end
end
