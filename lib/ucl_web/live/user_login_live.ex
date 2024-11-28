defmodule UclWeb.UserLoginLive do
  use UclWeb, :live_view_auth

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to your account

      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:emp_id]} type="text" label="Employee ID" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    emp_id = Phoenix.Flash.get(socket.assigns.flash, :emp_id)
    form = to_form(%{"emp_id" => emp_id}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
