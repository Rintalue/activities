defmodule UclWeb.RoomLive.FormComponent do
  use UclWeb, :live_component

  alias Ucl.Rooms.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage room records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="room-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Room</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    case Map.fetch(assigns, :room) do
      {:ok, room} ->
        {:ok,
         socket
         |> assign(assigns)
         |> assign(:form, to_form(Rooms.change_room(room)))
         |> assign(:current_user, assigns[:current_user])}

      :error ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset = Rooms.change_room(socket.assigns.room, room_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    save_room(socket, socket.assigns.action, room_params)
  end

  defp save_room(socket, :edit, room_params) do
    user_id = socket.assigns.current_user.id
  room_params_with_user = Map.put(room_params, "user_id", user_id)
    case Rooms.update_room(socket.assigns.room, room_params_with_user) do
      {:ok, room} ->
        notify_parent({:saved, room})

        {:noreply,
         socket
         |> put_flash(:info, "Room updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_room(socket, :new, room_params) do
    user_id = socket.assigns.current_user.id
    IO.inspect(user_id, label: "User")
    room_params_with_user = Map.put(room_params, "user_id", user_id)
    case Rooms.create_room(room_params_with_user) do
      {:ok, room} ->
        notify_parent({:saved, room})

        {:noreply,
         socket
         |> put_flash(:info, "Room created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
