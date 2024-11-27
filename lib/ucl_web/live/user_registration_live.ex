defmodule UclWeb.UserRegistrationLive do
  use UclWeb, :live_view_auth

  alias Ucl.Accounts
  alias Ucl.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen bg-gray-100">
    <div class="w-full max-w-2xl p-6 bg-white border-2 border-gray-200 rounded-lg shadow-xl"
      style="box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1), 0px 10px 20px rgba(0, 0, 0, 0.1);"
     >
    <.header class="text-center mb-6">
      Register for an account
      <:subtitle>
        Already registered?
        <.link navigate={~p"/users/log_in"} class="font-semibold text-blue-600 hover:underline">
          Log in
        </.link>
        to your account now.
      </:subtitle>
    </.header>

    <.simple_form
      for={@form}
      id="registration_form"
      phx-submit="save"
      phx-change="validate"
      phx-trigger-action={@trigger_submit}
      action={~p"/users/log_in?_action=registered"}
      method="post"
    >
      <.error :if={@check_errors}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <.input
          field={@form[:first_name]}
          type="text"
          label="First Name"
          required
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <.input
          field={@form[:second_name]}
          type="text"
          label="Last Name"
          required
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <.input
          field={@form[:emp_id]}
          type="text"
          label="Employee ID"
          required
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <.input
          field={@form[:email]}
          type="email"
          label="Email"
          required
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <.input
          field={@form[:username]}
          type="text"
          label="Username"
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <.input
          field={@form[:role]}
          type="text"
          label="Role"
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <.input
          field={@form[:department]}
          type="text"
          label="Department"
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <.input
          field={@form[:active]}
          type="select"
          label="Status"
          options={["active", "inactive"]}
          prompt="Choose status"
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>
      <div class="mt-6">
        <.input
          field={@form[:password]}
          type="password"
          label="Password"
          required
          class="w-full border border-gray-300 rounded-md p-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>
      <:actions>
        <.button
          phx-disable-with="Creating account..."
          class="w-full mt-6 bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700"
        >
          Create an account
        </.button>
      </:actions>
    </.simple_form>
       </div>
     </div>

    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: "Registration Errors")
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
