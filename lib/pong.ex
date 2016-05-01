defmodule Pong do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Pong.Router, []),
    ]

    opts = [strategy: :one_for_one, name: Pong.Supervisor]
    Supervisor.start_link(children, opts)
  end
  
  def boot do
    Pong.Ball.start_link
    Pong.Subs.start_link
    GenServer.cast(:ball, :move)
  end
end
