defmodule UclWeb.UclWeb.UserStopLive do
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
            Stop Your Activity
          </.header>

          <.simple_form for={@form} id="stop_activity_form" phx-submit="stop_activity" phx-update="ignore">
            <.input field={@form[:emp_id]} type="text" label="Employee ID" required />
            <.input field={@form[:password]} type="password" label="Password" required />

            <div class="flex items-center justify-between">
              <div>
                <.button phx-disable-with="Stopping activity..." class="w-full">
                  Stop Activity
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
    socket =
      socket
      |> assign(:form, to_form(%{"emp_id" => "", "password" => ""}, as: "activity"))
      |> assign(:show_modal, true)

    {:ok, socket}
  end

  @impl true
  def handle_event("stop_activity", %{"activity" => %{"emp_id" => emp_id, "password" => password}}, socket) do
    case Accounts.get_user_by_email_and_password(emp_id, password) do
      nil ->
        {:noreply, put_flash(socket, :error, "Invalid employee ID or password")}

      user ->
        case Activities.get_active_activity_by_emp_id(user.id) do
          nil ->
            {:noreply, put_flash(socket, :error, "No active activity found for this employee")}

          activity ->
            stop_time = DateTime.utc_now()
            stop_time_kenya = Timex.to_datetime(stop_time, "Africa/Nairobi")
            start_time_kenya = Timex.to_datetime(activity.start_time, "Africa/Nairobi")


duration =
  if start_time_kenya do
    Timex.diff(stop_time_kenya, start_time_kenya, :minutes)
  else
    0

              end

            attrs = %{
              stop_time: stop_time_kenya,
              duration: duration
            }

            case Activities.update_activity(activity, attrs) do
              {:ok, _updated_activity} ->
                socket =
                  socket
                  |> put_flash(:info, "Activity stopped successfully.")
                  |> assign(:show_modal, false)
                  |> redirect(to: "/")

                {:noreply, socket}

              {:error, changeset} ->
                IO.inspect(changeset.errors, label: "Update Activity Errors")
                {:noreply, socket}
            end
        end
    end
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end
end
