defmodule Clicky.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClickyWeb.Telemetry,
      Clicky.Repo,
      {DNSCluster, query: Application.get_env(:clicky, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Clicky.PubSub},
      Clicky.Grid,
      # Start a worker by calling: Clicky.Worker.start_link(arg)
      # {Clicky.Worker, arg},
      # Start to serve requests, typically the last entry
      ClickyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clicky.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClickyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
