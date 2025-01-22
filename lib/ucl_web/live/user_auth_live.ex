defmodule UclWeb.UserAuthLive do
  use UclWeb, :live_view_user

  alias Ucl.Accounts
  alias Ucl.Activities.Activities

  @impl true
  def render(assigns) do
    ~H"""
    <div class="modal-wrapper" :if={@show_modal}>
      <div class="modal-backdrop" phx-click="close_modal"></div>
      <div class="modal-content">
        <div class="mx-auto max-w-sm">
          <.header class="text-center">
            Log in to your account
          </.header>

          <.simple_form for={@form} id="login_form" phx-submit="login" phx-update="ignore">
            <.input field={@form[:emp_id]} type="text" label="Employee ID" required />
            <.input field={@form[:password]} type="password" label="Password" required />



            <div class="flex items-center justify-between">
              <div>


                  <.button phx-disable-with="Logging in..." class="w-full" style="margin-left:7pc;">
                    Log in
                  </.button>

              </div>
            </div>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end


  @impl true
  def mount(_params, _session, socket) do
    flash = socket.assigns.flash
    IO.inspect(flash, label: "Retrieved Flash")


  params = Map.get(flash, "params", %{})
  room_selected = Map.get(params, :room_id)
  type_selected = Map.get(params, :type_selected)
  sub_type_selected = Map.get(params, :sub_type_selected)
  batch_number = Map.get(params, :batch_number)
  product_id = Map.get(params, :product_id)
  product_description = Map.get(params, :product_description)



    socket =
      socket
      |> assign(:form, to_form(%{"emp_id" => "", "password" => ""}, as: "user"))
      |> assign(:room_id, room_selected)
      |> assign(:type_selected, type_selected)
      |> assign(:sub_type_selected, sub_type_selected)
      |> assign(:batch_number, batch_number)
      |> assign(:product_id, product_id)
      |> assign(:product_description, product_description)
      |> assign(:show_modal, true)

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
          |> assign(:show_modal, false)

          |> redirect(to: "/user/activities")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, true)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end


  defp save_activity(socket, :new, activity_params, user_id) do
    type =
      cond do
        socket.assigns[:sub_type_selected] && socket.assigns[:sub_type_selected] != "" ->
          socket.assigns[:sub_type_selected]

        socket.assigns[:type_selected] && socket.assigns[:type_selected] != "" ->
          socket.assigns[:type_selected]

        true ->
          nil
      end

    batch_number = socket.assigns.batch_number
    product_id = socket.assigns.product_id
    product_description = socket.assigns.product_description
    room_id = socket.assigns.room_id
    current_time_naive = DateTime.utc_now()
    current_time = Timex.to_datetime(current_time_naive, "Africa/Nairobi")

    new_activity_params =
      Map.put(activity_params, "user_id", user_id)
      |> Map.put("start_time", current_time)
      |> Map.put("room_id", room_id)
      |> Map.put("type", type)
      |> Map.put("batch_number", batch_number)
      |> Map.put("product_id", product_id)
      |> Map.put("product_description", product_description)

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
