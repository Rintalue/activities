defmodule UclWeb.ActivityLive.FormComponent do
  use UclWeb, :live_component

  alias Ucl.Activities.Activities

  @impl true
  def render(assigns) do

    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="activity-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if is_nil(@room_selected) and is_nil(@start_time) do %>
          <div class="button-group">
            <.input
              field={@form[:room_id]}
              type="select"
              label="Choose Room"
              options={@rooms}
              class="touch-select"
              prompt="Choose room"
              phx-change="room_selected"
            />
          </div>
        <% end %>
        <%= if !@type_selected and is_nil(@start_time) and @room_selected do %>
          <div class="button-group">
            <.input
              field={@form[:type]}
              type="select"
              label="Choose an Activity"
              options={["Operations", "Cleaning", "Maintenance"]}
              prompt="Choose activity"
              phx-change="activity_selected"
              class="touch-select"
            />
          </div>
        <% end %>
        <%= if @type_selected == "Cleaning" do %>
          <div class="button-group">
            <.input
              field={@form[:sub_type]}
              type="select"
              label="Choose Cleaning Type"
              options={@type_options}
              class="touch-select"
              prompt="Choose cleaning type"
              phx-change="sub_type_selected"
            />
          </div>
        <% end %>
        <%= if @type_selected == "Operations" do %>
          <.input
            field={@form[:sub_type]}
            type="hidden"
            options={@type_options}
            phx-change="sub_type_selected"
          />
        <% end %>
        <%= if @type_selected == "Maintenance" do %>
          <.input field={@form[:batch_number]} type="text" label="Batch Number" />
          <.input field={@form[:product_id]} type="text" label="Product ID" />
        <% end %>

        <:actions>
          <%= if @form[:type] do %>
            <.button phx-disable-with="Starting..." class="button1">Start Activity</.button>
          <% end %>
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
     |> assign(:room_selected, nil)
     |> assign(:type_selected, false)
     |> assign(:start_time, nil)
     |> assign_new(:form, fn ->
       to_form(Activities.change_activity(activity))
     end)}
  end

  @impl true
  def handle_event("room_selected", %{"activity" => %{"room_id" => room_id}}, socket) do
    IO.inspect(room_id, label: "Room ID selected")
    updated_form = Map.put(socket.assigns.form, :room_id, room_id)
    {:noreply, assign(socket, form: updated_form, room_selected: room_id)}
  end

  @impl true
  def handle_event("activity_selected", %{"activity" => %{"type" => type}}, socket) do
    IO.inspect(type, label: "Type")

    new_options =
      case type do
        "Cleaning" -> ["Serialised Cleaning", "Non-Serialised Cleaning"]
        "Operations" -> []
        "Maintenance" -> []
        _ -> []
      end

    {:noreply,
     assign(socket,
       type_options: new_options,
       type_selected: type,
       sub_type_selected: nil
     )}
  end

  @impl true
  def handle_event("sub_type_selected", %{"activity" => %{"sub_type" => sub_type}}, socket) do
    IO.inspect(sub_type, label: "Sub Type Selected")
    updated_form = Map.put(socket.assigns.form, :type, sub_type)

    {:noreply, assign(socket, form: updated_form, sub_type_selected: sub_type)}
  end

  @impl true
  def handle_event("validate", %{"activity" => activity_params}, socket) do
    changeset = Activities.change_activity(socket.assigns.activity, activity_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"activity" => activity_params}, socket) do
    IO.inspect(activity_params, label: "Activity Params")
    save_activity(socket, socket.assigns.action, activity_params)
  end

  defp save_activity(socket, :edit, activity_params) do
    user_id = socket.assigns.current_user.id
    current_time = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

    new_activity_params =
      Map.put(activity_params, "user_id", user_id)
      |> Map.put("start_time", current_time)
      |> Map.put("room_id", socket.assigns.form.room_id)
      |> Map.put("type", socket.assigns.form.type)

    IO.inspect(new_activity_params, label: "Activity Params")

    case Activities.update_activity(socket.assigns.activity, new_activity_params) do
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
    type = socket.assigns.sub_type_selected ||  socket.assigns.type_selected

    room_id = socket.assigns.room_selected

    current_time = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

    new_activity_params =
      Map.put(activity_params, "user_id", user_id)
      |> Map.put("start_time", current_time)
      |> Map.put("room_id", room_id)
      |> Map.put("type", type)

    IO.inspect(new_activity_params, label: "New Activity Params")

    case Activities.create_activity(new_activity_params) do
      {:ok, activity} ->
        notify_parent({:saved, activity})

        {:noreply,
         socket
         |> put_flash(:info, "Activity  Started")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
