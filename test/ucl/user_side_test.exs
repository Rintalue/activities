defmodule Ucl.UserSideTest do
  use Ucl.DataCase

  alias Ucl.UserSide

  describe "userside" do
    alias Ucl.UserSide.UserSideLive

    import Ucl.UserSideFixtures

    @invalid_attrs %{email: nil, name: nil, role: nil}

    test "list_userside/0 returns all userside" do
      user_side_live = user_side_live_fixture()
      assert UserSide.list_userside() == [user_side_live]
    end

    test "get_user_side_live!/1 returns the user_side_live with given id" do
      user_side_live = user_side_live_fixture()
      assert UserSide.get_user_side_live!(user_side_live.id) == user_side_live
    end

    test "create_user_side_live/1 with valid data creates a user_side_live" do
      valid_attrs = %{email: "some email", name: "some name", role: "some role"}

      assert {:ok, %UserSideLive{} = user_side_live} = UserSide.create_user_side_live(valid_attrs)
      assert user_side_live.email == "some email"
      assert user_side_live.name == "some name"
      assert user_side_live.role == "some role"
    end

    test "create_user_side_live/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserSide.create_user_side_live(@invalid_attrs)
    end

    test "update_user_side_live/2 with valid data updates the user_side_live" do
      user_side_live = user_side_live_fixture()
      update_attrs = %{email: "some updated email", name: "some updated name", role: "some updated role"}

      assert {:ok, %UserSideLive{} = user_side_live} = UserSide.update_user_side_live(user_side_live, update_attrs)
      assert user_side_live.email == "some updated email"
      assert user_side_live.name == "some updated name"
      assert user_side_live.role == "some updated role"
    end

    test "update_user_side_live/2 with invalid data returns error changeset" do
      user_side_live = user_side_live_fixture()
      assert {:error, %Ecto.Changeset{}} = UserSide.update_user_side_live(user_side_live, @invalid_attrs)
      assert user_side_live == UserSide.get_user_side_live!(user_side_live.id)
    end

    test "delete_user_side_live/1 deletes the user_side_live" do
      user_side_live = user_side_live_fixture()
      assert {:ok, %UserSideLive{}} = UserSide.delete_user_side_live(user_side_live)
      assert_raise Ecto.NoResultsError, fn -> UserSide.get_user_side_live!(user_side_live.id) end
    end

    test "change_user_side_live/1 returns a user_side_live changeset" do
      user_side_live = user_side_live_fixture()
      assert %Ecto.Changeset{} = UserSide.change_user_side_live(user_side_live)
    end
  end
end
