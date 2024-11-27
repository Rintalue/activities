defmodule UclWeb.ActivityLive.FormComponent do
  use UclWeb, :live_component

  alias Ucl.Activities.Activities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage activity records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="activity-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:type]}
          type="select"
          label="Type of Activity"
          options={["Cleaning", "Maintaining a Machine"]}
          prompt="choose activity"
        />
        <.input field={@form[:start_time]} type="datetime-local" label="Start time" />
        <.input field={@form[:stop_time]} type="datetime-local" label="Stop time" />
        <.input field={@form[:product_batch]} type="textarea" label="Description" />

        <.input field={@form[:room_id]} type="select"  options={@rooms} label="Room" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Activity</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{activity: activity} = assigns, socket) do
    rooms = Ucl.Rooms.Rooms.list_rooms()
    room_options = Enum.map(rooms, fn room -> {room.name, room.id} end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:rooms, room_options)
     |> assign_new(:form, fn ->
       to_form(Activities.change_activity(activity))
     end)}
  end

  @impl true
  def handle_event("validate", %{"activity" => activity_params}, socket) do
    changeset = Activities.change_activity(socket.assigns.activity, activity_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"activity" => activity_params}, socket) do
    save_activity(socket, socket.assigns.action, activity_params)
  end

  defp save_activity(socket, :edit, activity_params) do
    user_id = socket.assigns.current_user.id
  activity_params_with_user = Map.put(activity_params, "user_id", user_id)

    case Activities.update_activity(socket.assigns.activity, activity_params_with_user) do
      {:ok, activity} ->
        notify_parent({:saved, activity})

        {:noreply,
         socket
         |> put_flash(:info, "Activity updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_activity(socket, :new, activity_params) do
    user_id = socket.assigns.current_user.id
  activity_params_with_user = Map.put(activity_params, "user_id", user_id)

    case Activities.create_activity(activity_params_with_user) do
      {:ok, activity} ->
        notify_parent({:saved, activity})

        {:noreply,
         socket
         |> put_flash(:info, "Activity created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
