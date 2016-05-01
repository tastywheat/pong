defmodule Pong.Subs do
    use GenServer
    
    def start_link do
        GenServer.start_link(__MODULE__, [], name: :subs)
    end

    def subscribe(pid) do
        GenServer.cast(:subs, {:subscribe, pid})
    end
    
    def send(message) do
        GenServer.cast(:subs, {:send, message})
    end
    
    def handle_cast({:subscribe, pid}, state) do
        {:noreply, [pid | state]}
    end
    
    def handle_cast({:send, message}, state) do
        # IO.inspect state
        Enum.each(state, &(send(&1, message)))
        {:noreply, state}
    end
    
    def handle_call(:get_state, _from, state) do
        {:reply, state, state}
    end
end