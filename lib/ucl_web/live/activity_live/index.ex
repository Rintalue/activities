defmodule UclWeb.ActivityLive.Index do
  use UclWeb, :live_view_ucl

  alias Ucl.Activities.Activities
  alias Ucl.Activities.Activity


  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      IO.inspect(socket, label: "Socket is connected")
    else
      IO.inspect(socket, label: "Socket is not connected yet")
    end
    IO.inspect(socket, label: "Socket")
    {:ok, stream(socket, :activities, Activities.list_activities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Activity")
    |> assign(:activity, Activities.get_activity!(id))
  end

  defp apply_action(socket, :new, _params) do
    IO.inspect(socket, label: "Socket in :new")
    socket
    |> assign(:page_title, "New Log")

    |> assign(:activity, %Activity{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Activities")
    |> assign(:activity, nil)
  end

  @impl true
  @spec handle_info(
          {UclWeb.ActivityLive.FormComponent, {:saved, any()}},
          Phoenix.LiveView.Socket.t()
        ) :: {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({UclWeb.ActivityLive.FormComponent, {:saved, activity}}, socket) do
    {:noreply, stream_insert(socket, :activities, activity)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity = Activities.get_activity!(id)
    {:ok, _} = Activities.delete_activity(activity)

    {:noreply, stream_delete(socket, :activities, activity)}
  end
end
