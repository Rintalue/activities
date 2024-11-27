defmodule UclWeb.UserLive.Index do
  use UclWeb, :live_view_ucl

  alias Ucl.Accounts
  alias Ucl.Accounts.User

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil ->
        {:ok, redirect(socket, to: "/users/register")}

      current_user ->
        IO.inspect(current_user, label: "Current User")
        if current_user.id == 6 do
          {:ok,
           socket
           |> assign(:current_user, current_user)
           |> stream(:users, Accounts.list_users())}
        else
          {:ok,
           socket
           |> assign(:current_user, current_user)
           |> stream(:users, [current_user])}
        end
    end
  end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({UclWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end
end
