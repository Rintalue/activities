defmodule Ucl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UclWeb.Telemetry,
      Ucl.Repo,
      {DNSCluster, query: Application.get_env(:ucl, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ucl.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ucl.Finch},
      # Start a worker by calling: Ucl.Worker.start_link(arg)
      # {Ucl.Worker, arg},
      # Start to serve requests, typically the last entry
      UclWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ucl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UclWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
