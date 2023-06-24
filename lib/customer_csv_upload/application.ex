defmodule CustomerCsvUpload.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CustomerCsvUpload.Repo,
      # Start the Telemetry supervisor
      CustomerCsvUploadWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CustomerCsvUpload.PubSub},
      # Start the Endpoint (http/https)
      CustomerCsvUploadWeb.Endpoint
      # Start a worker by calling: CustomerCsvUpload.Worker.start_link(arg)
      # {CustomerCsvUpload.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CustomerCsvUpload.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CustomerCsvUploadWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
