defmodule UclWeb.UserSessionController do
  use UclWeb, :controller

  alias Ucl.Accounts
  alias UclWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
  case Accounts.register_user(params["user"]) do
    {:ok, user} ->
      UserAuth.log_in_user(conn, user, params["user"])
      |> put_flash(:info, "Account created successfully!")
      |> redirect(to: params["return_to"])

    {:error, changeset} ->
      put_flash(conn, :error, "Failed to create account")
      |> render( changeset: changeset)
  end
end


  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"emp_id" => emp_id, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(emp_id, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)


    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid employee id or password")

      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

end
