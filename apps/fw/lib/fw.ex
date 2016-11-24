defmodule Fw do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # worker(Fw.Worker, [arg1, arg2, arg3]),
      worker(Task, [fn -> start_network end], restart: :transient),
      worker(Fw.Worker, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_network do
    opts = Application.get_env(:fw, :wlan0)
    Nerves.InterimWiFi.setup "wlan0", opts
    {:ok, self}
  end
end
