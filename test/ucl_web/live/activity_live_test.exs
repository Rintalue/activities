defmodule UclWeb.ActivityLiveTest do
  use UclWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ucl.ActivitiesFixtures

  @create_attrs %{batch_number: "some product_batch", start_time: "2024-11-19T11:55:00", stop_time: "2024-11-19T11:55:00", type: "some type"}
  @update_attrs %{batch_number: "some updated product_batch", start_time: "2024-11-20T11:55:00", stop_time: "2024-11-20T11:55:00", type: "some updated type"}
  @invalid_attrs %{batch_number: nil, start_time: nil, stop_time: nil, type: nil}

  defp create_activity(_) do
    activity = activity_fixture()
    %{activity: activity}
  end

  describe "Index" do
    setup [:create_activity]

    test "lists all activities", %{conn: conn, activity: activity} do
      {:ok, _index_live, html} = live(conn, ~p"/activities")

      assert html =~ "Listing Activities"
      assert html =~ activity.batch_number
    end

    test "saves new activity", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/activities")

      assert index_live |> element("a", "New Activity") |> render_click() =~
               "New Activity"

      assert_patch(index_live, ~p"/activities/new")

      assert index_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#activity-form", activity: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/activities")

      html = render(index_live)
      assert html =~ "Activity created successfully"
      assert html =~ "some batch_number"
    end

    test "updates activity in listing", %{conn: conn, activity: activity} do
      {:ok, index_live, _html} = live(conn, ~p"/activities")

      assert index_live |> element("#activities-#{activity.id} a", "Edit") |> render_click() =~
               "Edit Activity"

      assert_patch(index_live, ~p"/activities/#{activity}/edit")

      assert index_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#activity-form", activity: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/activities")

      html = render(index_live)
      assert html =~ "Activity updated successfully"
      assert html =~ "some updated product_batch"
    end

    test "deletes activity in listing", %{conn: conn, activity: activity} do
      {:ok, index_live, _html} = live(conn, ~p"/activities")

      assert index_live |> element("#activities-#{activity.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#activities-#{activity.id}")
    end
  end

  describe "Show" do
    setup [:create_activity]

    test "displays activity", %{conn: conn, activity: activity} do
      {:ok, _show_live, html} = live(conn, ~p"/activities/#{activity}")

      assert html =~ "Show Activity"
      assert html =~ activity.batch_number
    end

    test "updates activity within modal", %{conn: conn, activity: activity} do
      {:ok, show_live, _html} = live(conn, ~p"/activities/#{activity}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Activity"

      assert_patch(show_live, ~p"/activities/#{activity}/show/edit")

      assert show_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#activity-form", activity: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/activities/#{activity}")

      html = render(show_live)
      assert html =~ "Activity updated successfully"
      assert html =~ "some updated product_batch"
    end
  end
end
