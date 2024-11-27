defmodule UclWeb.UserSettingsLive do
  use UclWeb, :live_view_auth

  alias Ucl.Accounts

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-6 py-12">
      <.header class="text-center mb-10">
        <h1 class="text-3xl font-bold text-gray-800">Account Settings</h1>
        <p class="text-gray-600 mt-2">Manage your account email address and password settings</p>
      </.header>

      <div class="space-y-12 divide-y divide-gray-300">
        <!-- Email Form -->
        <div class="pt-8">
          <h2 class="text-xl font-semibold text-gray-700">Update Email</h2>
          <p class="text-gray-500 mt-1">Change your account's email address.</p>
          <.simple_form
            for={@email_form}
            id="email_form"
            class="mt-6 space-y-4"
            phx-submit="update_email"
            phx-change="validate_email"
          >
            <.input field={@email_form[:email]} type="email" label="New Email" required class="w-full" />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Current Password"
              value={@email_form_current_password}
              required
              class="w-full"
            />
            <:actions>
              <.button class="w-full bg-blue-500 text-white py-2 px-4 rounded-lg hover:bg-blue-600">
                Change Email
              </.button>
            </:actions>
          </.simple_form>
        </div>

        <!-- Password Form -->
        <div class="pt-8">
          <h2 class="text-xl font-semibold text-gray-700">Update Password</h2>
          <p class="text-gray-500 mt-1">Change your account's password.</p>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
            class="mt-6 space-y-4"
          >
            <input
              name={@password_form[:email].name}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
            <.input field={@password_form[:password]} type="password" label="New Password" required class="w-full" />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm New Password"
              required
              class="w-full"
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label="Current Password"
              id="current_password_for_password"
              value={@current_password}
              required
              class="w-full"
            />
            <:actions>
              <.button class="w-full bg-green-500 text-white py-2 px-4 rounded-lg hover:bg-green-600">
                Change Password
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
