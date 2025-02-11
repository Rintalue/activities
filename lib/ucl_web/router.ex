defmodule UclWeb.Router do
  alias UclWeb.UserStopLive
  alias UclWeb.RoomReportLive
  use UclWeb, :router

  import UclWeb.UserAuth


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UclWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  pipeline :check_user_id do
    plug UclWeb.CheckUserId
  end
  scope "/", UclWeb do
    pipe_through :browser

    get "/", PageController, :home






  end

  # Other scopes may use custom stacks.
  # scope "/api", UclWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ucl, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UclWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", UclWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{UclWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/login", UserAuthLive,  :new
      live "/stop", UserStopLive , :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit


    end

    post "/users/log_in", UserSessionController, :create




  end

  scope "/", UclWeb do
    pipe_through [:browser, :require_authenticated_user, :check_user_id]

    live_session :require_authenticated_user,
      on_mount: [{UclWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/rooms", RoomLive.Index, :index
      live "/rooms/new", RoomLive.Index, :new
      live "/rooms/:id/edit", RoomLive.Index, :edit

      live "/rooms/:id", RoomLive.Show, :show
      live "/rooms/:id/show/edit", RoomLive.Show, :edit

      live "/activities", ActivityLive.Index, :index
      live "/activities/new", ActivityLive.Index, :new
      live "/activities/:id/edit", ActivityLive.Index, :edit

      live "/activities/:id", ActivityLive.Show, :show
      live "/activities/:id/show/edit", ActivityLive.Show, :edit

      live "/users", UserLive.Index, :index
      live "/users/new", UserLive.Index, :new
      live "/users/:id/edit", UserLive.Index, :edit

      live "/room/reports", RoomReportLive.Index, :index
      get "/room_report/download/:room_id", ReportController, :download_report



    end
  end


  scope "/", UclWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/log_out", UserSessionController, :delete


    live_session :current_user,
      on_mount: [{UclWeb.UserAuth, :mount_current_user}] do

        live "/user/activities", UserSideLive.Index, :index
      live "/user/activities/new", UserSideLive.Index, :new
      live "/user/activities/:id/edit", UserSideLive.Index, :edit


      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
