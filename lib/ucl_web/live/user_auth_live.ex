defmodule UclWeb.UserAuthLive do
  use UclWeb, :live_view_user

  alias Ucl.Accounts
  alias Ucl.Activities.Activities

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to your account
      </.header>

      <.simple_form for={@form} id="login_form" phx-submit="login" phx-update="ignore">
        <.input field={@form[:emp_id]} type="text" label="Employee ID" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>

        <div class="flex items-center justify-between">
          <div>
            <%= if @room_id && @type_selected && @sub_type_selected do %>
              <.button phx-disable-with="Logging in..." class="w-full">
                Log in to start activity
              </.button>
            <% else %>
              <.button phx-disable-with="Logging in..." class="w-full">
                Log in
              </.button>
            <% end %>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    IO.inspect(params, label: "params in mount")

    room_selected = Map.get(params, "room_id")
    type_selected = Map.get(params, "type_selected")
    sub_type_selected = Map.get(params, "sub_type_selected")

    socket =
      socket
      |> assign(:form, to_form(%{"emp_id" => "", "password" => ""}, as: "user"))
      |> assign(:room_id, room_selected)
      |> assign(:type_selected, type_selected)
      |> assign(:sub_type_selected, sub_type_selected)

    {:ok, socket}
  end

  @impl true
  def handle_event("login", %{"user" => %{"emp_id" => emp_id, "password" => password}}, socket) do
    case Accounts.get_user_by_email_and_password(emp_id, password) do
      nil ->
        {:noreply, put_flash(socket, :error, "Invalid employee ID or password")}

      user ->

        save_activity(socket, :new, %{}, user.id)
        socket = assign(socket, :current_user, user)
        IO.inspect(socket, label: "socket with user")

        socket =
          socket
          |> put_flash(:info, "Activity started.")
          |> redirect(to: "/user/activities")

        {:noreply, socket}
    end
  end


  defp save_activity(socket, :new, activity_params, user_id) do
    type = socket.assigns.sub_type_selected || socket.assigns.type_selected
    room_id = socket.assigns.room_id
    current_time_naive = DateTime.utc_now()
    current_time = Timex.to_datetime(current_time_naive, "Africa/Nairobi")

    new_activity_params =
      Map.put(activity_params, "user_id", user_id)
      |> Map.put("start_time", current_time)
      |> Map.put("room_id", room_id)
      |> Map.put("type", type)

    IO.inspect(new_activity_params, label: "New Activity Params")

    case Activities.create_activity(new_activity_params) do
      {:ok, activity} ->
        notify_parent({:saved, activity})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
