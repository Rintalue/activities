defmodule UclWeb.UserSideLive.Index do
  use UclWeb, :live_view_user

  alias Ucl.Activities.Activities
  alias Ucl.Activities.Activity


  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:activities, [])

    case socket.assigns[:current_user] do
      nil ->
        {:ok, socket
        |> assign(:current_user, nil)
        |> assign(:room_selected, nil)
        |> assign(:type_selected, nil)
        |> assign(:sub_type_selected, nil)
        }

      current_user ->
        IO.inspect(current_user, label: "Current User")
        activities = Activities.list_activities_for_user(current_user.id)

        {:ok,
         socket
         |> assign(:current_user, current_user)
         |> stream(:activities, activities)}
    end
  end


  @impl true
  def handle_info({UclWeb.UserSideLive.FormComponent, {:saved, activity}}, socket) do
    {:noreply, stream_insert(socket, :activities, activity)}
  end



  @impl true
  def handle_event("stop_activity", %{"id" => id}, socket) do
    activity = Activities.get_activity!(id)

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
      {:ok, updated_activity} ->
        socket =
          socket
          |> put_flash(:info, "Activity stopped successfully.")
          |> stream_insert(:activities, updated_activity)

        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect(changeset.errors, label: "Update Activity Errors")
        {:noreply, socket}
    end
  end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity = Activities.get_activity!(id)
    {:ok, _} = Activities.delete_activity(activity)

    {:noreply, stream_delete(socket, :activities, activity)}
  end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end


  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Activity")
    |> assign(:activity, Activities.get_activity!(id))
    |> assign(:live_action, :edit)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Log")
    |> assign(:live_action, :new)
    |> assign(:activity, %Activity{})
  end


  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Activities")
    |> assign(:live_action, :index)
    |> assign(:activity, nil)
  end
end
