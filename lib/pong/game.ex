defmodule Pong.Game do
    use GenServer
    
    
    def create_game do
        import Supervisor.Spec, warn: false

        children = [
            worker(Pong.Router, []),
            worker(Pong.Game, [])
        ]

        opts = [strategy: :simple_one_for_one, name: Pong.Game.Supervisor]
        Supervisor.start_link(children, opts)
    end
end