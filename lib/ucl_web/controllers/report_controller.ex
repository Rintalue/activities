defmodule UclWeb.ReportController do
  use UclWeb, :controller
  alias Ucl.Activities.Activities
  alias Ucl.Rooms.Rooms

  def download_report(conn, %{"room_id" => room_id}) do

    activities = Activities.list_activities_by_room(room_id)

    csv_data = generate_csv(activities)


    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=room_#{room_id}_report.csv")
    |> send_resp(200, csv_data)
  end

  defp generate_csv(activities) do
    headers = ["First Name", "Second Name", "Employee ID", "Type", "Room", "Start Time", "Stop Time"]


    rows = Enum.map(activities, fn activity ->
      [
        activity.user.first_name,
        activity.user.second_name,
        activity.user.emp_id,
        activity.type,
        Rooms.get_room_name(activity.room_id).name,
        activity.start_time,
        activity.stop_time
      ]
    end)

    all_data = [headers | rows]

    all_data
    |> CSV.encode()
    |> Enum.to_list()
    |> IO.iodata_to_binary()
  end
end
