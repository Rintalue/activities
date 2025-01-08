defmodule UclWeb.UclWeb.RoomReportLive.Index do
  use UclWeb, :live_view_ucl

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Room Activity Report")
     |> assign(:rooms, fetch_rooms())
     |> assign(:activity_data, %{
       report_activities: []
     })
     |> assign(:room_id, nil)
     |> assign(:results_style, "display: none;")
     |> assign(:total_activities, 0)}
  end

  defp fetch_rooms do
    Ucl.Rooms.Rooms.list_rooms()
    |> Enum.map(fn room -> {room.name, room.id} end)
  end

  @impl true
  def handle_event("search-room", %{"room" => room_id}, socket) do
    activities = fetch_activities_by_room(room_id)

    {:noreply,
     socket
     |> assign(:activity_data, %{report_activities: activities})
     |> assign(:room_id, room_id)
     |> assign(:results_style, "display: block;")
     |> assign(:total_activities, length(activities))}
  end

  defp fetch_activities_by_room(room_id) do
    Ucl.Activities.Activities.list_activities_by_room(room_id)
    |> Enum.map(fn activity ->
      %{
        first_name: activity.user.first_name,
        second_name: activity.user.second_name,
        emp_id: activity.user.emp_id,
        type: activity.type,
        room: Ucl.Rooms.Rooms.get_room_name(activity.room_id).name,
        start_time: activity.start_time,
        stop_time: activity.stop_time,
        duration: activity.duration,
        batch_number: activity.batch_number,
        product_id: activity.product_id
      }
    end)
  end

end
