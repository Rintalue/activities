defmodule UclWeb.UserSideLive.FormComponent do
  use UclWeb, :live_component

  alias Ucl.Activities.Activities


  @impl true
  def render(assigns) do
    ~H"""

    <div style="background:#dddde1;">
      <.simple_form
        for={@form}
        id="activity-form2"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <%= if is_nil(@room_selected) do %>

        <div>
            <label class="option">Choose Room</label>
            <div class="view-button">
              <%= for {room_name, room_id} <- @rooms do %>
                <button
                  type="button"
                  phx-click="room_selected"
                  phx-value-room_id={room_id}
                  class="button"
                  phx-target={@myself}
                  style="padding: 10px; border-radius: 5px;  border: 1px solid #ccc; font-size: 16px; margin: 5px;"
                >
                  <%= room_name %>
                </button>
              <% end %>
            </div>
          </div>

        <% end %>

        <%= if @room_selected && !@type_selected do %>
  <div>
    <label class="option">Choose an Activity</label>
    <div class="view-button">
      <%= for activity <- ["Operations", "Cleaning", "Maintenance"] do %>
        <button
          type="button"
          phx-click="activity_selected"
          phx-value-type={activity}
          phx-target={@myself}
          class="button"
          style="padding: 10px; border-radius: 5px; border: 1px solid #ccc; font-size: 16px; margin: 5px;"
        >
          <%= activity %>
        </button>
      <% end %>
    </div>
  </div>
<% end %>



<%= if @type_selected == "Cleaning" && !@sub_type_selected do %>
  <div>
    <label class="option">Choose Cleaning Type</label>
    <div class="view-button">
      <%= for sub_type <- @type_options do %>
        <button
          type="button"
          phx-click="sub_type_selected"
          phx-value-sub_type={sub_type}
          phx-target={@myself}
          class="button"
          style="padding: 10px; border-radius: 5px; border: 1px solid #ccc; font-size: 16px; margin: 5px;"
        >
          <%= sub_type %>
        </button>
      <% end %>
    </div>
  </div>
<% end %>



        <%= if @type_selected == "Maintenance" do %>
          <.input field={@form[:batch_number]} type="text" label="Batch Number" />
          <.input field={@form[:product_id]} type="text" label="Product ID" />
        <% end %>

        <%= if @type_selected == "Operations" do %>
          <.input
            field={@form[:sub_type]}
            type="hidden"
            options={@type_options}
            phx-change="sub_type_selected"
          />
        <% end %>
        <input type="hidden" name="activity[room_id]" value={@room_selected} />
<input type="hidden" name="activity[type]" value={@type_selected} />
<input type="hidden" name="activity[sub_type]" value={@sub_type_selected || ""} />

        <:actions>
  <div style="margin-left:12pc;">
    <%= if all_fields_selected?(
      @room_selected,
      @type_selected,
      @sub_type_selected,
      @form[:batch_number],
      @form[:product_id]
    ) do %>
      <.button phx-disable-with="Starting..." class="button1">Start Activity</.button>
    <% end %>
  </div>
</:actions>

      </.simple_form>
    </div>

    """
  end

defp all_fields_selected?(
  room_selected,
  type_selected,
  sub_type_selected,
  batch_number,
  product_id
) do
cond do
type_selected == "Maintenance" ->
 room_selected && batch_number && product_id

type_selected == "Cleaning" ->
 room_selected && sub_type_selected

type_selected == "Operations" ->
 room_selected

true ->
 false
end
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
     |> assign(:sub_type_selected, nil)
     |> assign(:type_selected, false)
     |> assign(:start_time, nil)
     |> assign_new(:form, fn ->
       to_form(Activities.change_activity(activity))
     end)}
  end

  @impl true
  def handle_event("room_selected",  %{"room_id" => room_id}, socket) do
    IO.inspect(room_id, label: "Room ID selected")
    updated_form = Map.put(socket.assigns.form, :room_id, room_id)
    {:noreply, assign(socket, form: updated_form, room_selected: room_id)}
  end

  @impl true
  def handle_event("activity_selected", %{"type" => type}, socket) do
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
  def handle_event("sub_type_selected", %{"sub_type" => sub_type}, socket) do
    IO.inspect(sub_type, label: "Sub Type Selected")
    updated_form = Map.put(socket.assigns.form, :type, sub_type)

    {:noreply, assign(socket, form: updated_form, sub_type_selected: sub_type)}
  end

  @impl true
  def handle_event("validate", %{"activity" => activity_params}, socket) do
    changeset = Activities.change_activity(socket.assigns.activity, activity_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end
  @impl true
  def handle_event("save", %{"activity" => activity_params}, socket) do
    current_user = socket.assigns[:current_user]

    if current_user do
      save_activity(socket, socket.assigns.action, activity_params)
    else
      room_selected = socket.assigns.room_selected
      type_selected = socket.assigns.type_selected
      sub_type_selected = socket.assigns.sub_type_selected
      batch_number = if type_selected == "Maintenance", do: activity_params["batch_number"], else: nil
      product_id = if type_selected == "Maintenance", do: activity_params["product_id"], else: nil

      params = %{
        room_id: room_selected,
        type_selected: type_selected,
        sub_type_selected: sub_type_selected,
        batch_number: batch_number,
        product_id: product_id
      }

      IO.inspect(params, label: "Redirect Params")


    {:noreply,
    socket
    |> put_flash(:params, params)
 |> redirect(to: "/login")}
    end
end
@impl true
def handle_event("save", %{"activity" => activity_params}, socket) do
  # Handle the save logic based on the selected fields
  current_user = socket.assigns[:current_user]

  if current_user do
    save_activity(socket, socket.assigns.action, activity_params)
  else
    # Extract parameters with proper fallback values
    room_selected = activity_params["room_id"] || socket.assigns.room_selected
    type_selected = activity_params["type"] || socket.assigns.type_selected
    sub_type_selected = activity_params["sub_type"] || socket.assigns.sub_type_selected

    batch_number =
      if type_selected == "Maintenance", do: activity_params["batch_number"], else: nil

    product_id =
      if type_selected == "Maintenance", do: activity_params["product_id"], else: nil

    params = %{
      room_id: room_selected,
      type_selected: type_selected,
      sub_type_selected: sub_type_selected,
      batch_number: batch_number,
      product_id: product_id
    }

    IO.inspect(params, label: "Redirect Params")

    {:noreply,
     socket
     |> put_flash(:params, params)
     |> redirect(to: "/login")}
  end
end



  defp save_activity(socket, :edit, activity_params) do
    user_id = socket.assigns.current_user.id


    IO.inspect(user_id, label: "User ID")

 current_time_naive = DateTime.utc_now()
current_time = Timex.to_datetime(current_time_naive, "Africa/Nairobi")
IO.inspect(current_time, label: "Time")
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
    type = socket.assigns.sub_type_selected || socket.assigns.type_selected
    room_id = socket.assigns.room_selected
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

        {:noreply,
         socket
         |> put_flash(:info, "Activity Started")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
