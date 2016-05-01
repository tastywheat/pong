defmodule Pong.Router do
    use Plug.Router
    
    plug Plug.Logger
    plug Plug.Parsers, parsers: [:urlencoded, :json],
                       pass:  ["text/*", "application/*"],
                       json_decoder: Poison
    plug Plug.Static, 
        at: "/", 
        from: :pong
    plug :match
    plug :dispatch
    
    def start_link do
        Plug.Adapters.Cowboy.http(__MODULE__, [], [port: 4009, dispatch: dispatch])
    end
    
    defp dispatch do
        [
            {:_, [
                {"/ws", Pong.SocketHandler, []},
                {:_, Plug.Adapters.Cowboy.Handler, {Pong.Router, []}}
            ]}
        ]
    end

    # forward "/users", to: API.Router.Users

    get "/" do
        send_resp(conn, 200, "Plug!")
    end
    
    match _ do
        send_resp(conn, 200, "wtf")
    end
end

