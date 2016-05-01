defmodule Pong.Ball do
    use GenServer
    
    defstruct position: %{ x: 250, y: 150 }, angle: 150
    
    @max_x 640
    @max_y 480
    
    # Client
    def start_link do
        initial_state = %Pong.Ball{}
        GenServer.start_link(__MODULE__, initial_state, name: :ball)
    end 
    
    
    def findDestination(_, y, 0), do: {@max_x, y}
    def findDestination(_, y, 180), do: {0, y}
    def findDestination(_, y, -180), do: {0, y}
    
    def findDestination(x, y, angle) do
    
        x_direction = cond do
            angle > 90 -> -1
            angle < -90 -> -1
            true -> 1
        end
        
        y_direction = cond do
            angle > 0 -> 1
            angle < 0 -> -1
        end
        
        a_side = cond do
            y_direction == 1 -> @max_y - y
            y_direction == -1 -> y
        end
        
        
        angle_abs = abs(angle)
    
        c_angle = cond do
            angle_abs > 90 -> 
                angle_abs - 90
            true ->
                angle_abs
        end
        
        a_angle = 180 - 90 - abs(c_angle)
        
        c_angle_in_radians = c_angle / 180 * :math.pi
        a_angle_in_radians = a_angle / 180 * :math.pi

        c_side = a_side * :math.sin(c_angle_in_radians) / :math.sin(a_angle_in_radians)
      
        case get_quadrant(angle) do
            1 -> {x - c_side, 0}
            2 -> {x + c_side, 0}
            3 -> {x - c_side, @max_y}
            4 -> {x + c_side, @max_y}
        end
    end 
    
    defp move(angle) do
    
        x = 15
    
        x_direction = cond do
            angle > 90 ->
                -1
            angle < -90 ->
                -1
            true ->
                1
        end
        
        y_direction = cond do
            angle > 0 ->
                1
            angle < 0 ->
                -1
            true ->
                1
        end
    
        angle_abs = abs(angle)
    
        angle_c = cond do
            angle_abs > 90 -> 
                180 - angle_abs
            true ->
                angle_abs
        end
        
        angle_a = 180 - 90 - abs(angle_c)
        
        angle_c_in_radians = angle_c / 180 * :math.pi
        angle_a_in_radians = angle_a / 180 * :math.pi
       
        y = x * :math.sin(angle_c_in_radians) / :math.sin(angle_a_in_radians)
        
        
        {x * x_direction, y * y_direction}
    end
    
    defp normalize_x(x) do
        x |> min(@max_x) |> max(0)        
    end
    
    defp normalize_y(y) do
        y |> min(@max_y) |> max(0)
    end
    
    defp get_side(x, y) do
        cond do
            x <= 0 -> "left"
            x >= @max_x ->"right"
            y <= 0 -> "top"
            y >= @max_y -> "bottom"
            true -> "unknown"
        end
    end
    
    defp get_quadrant(angle) do
        cond do
            angle >= -180 and angle < -90 -> 1
            angle < 0 and angle >= -90 -> 2
            angle >= 90 and angle <= 180 -> 3
            angle >= 0 and angle < 90 -> 4
            true -> 0
        end
    end
    
    defp get_side_and_quadrant(angle, x, y) do
        side = get_side(x, y)
        quadrant = get_quadrant(angle)
        {side, quadrant}
    end
    
    defp update_angle(angle, x, y) do
        IO.inspect get_side_and_quadrant(angle, x, y)
        case get_side_and_quadrant(angle, x, y) do
            {"top", 2} ->
                angle * -1
            {"top", 1} ->
                angle * -1
            {"right", 2} ->
                -90 + (-90 - angle)
            {"right", 4} ->
                90 + (90 - angle)
            {"bottom", 4} ->
                angle * -1
            {"bottom", 3} ->
                angle * -1
            {"left", 1} ->
                -90 - (angle - (-90))
            {"left", 3} ->
                90 - (angle - 90)
            _ ->
                angle
        end
    end
    
    
    # Server
    def init(state) do
        {:ok, state}
    end
    
    def handle_cast(:move, state) do

        {d_x, d_y} = move(state.angle)  
        
        next_x = state.position.x + d_x
        next_y = state.position.y + d_y
        
        next_angle = update_angle(state.angle, next_x, next_y)
        
        next_state = %Pong.Ball{
            position: %{
                x: normalize_x(next_x),
                y: normalize_y(next_y)
            },
            angle: next_angle
        }
        
        json = Poison.encode!(%{x: next_x, y: next_y, angle: next_angle})
        Pong.Subs.send(json)
        
        :timer.apply_after(60, GenServer, :cast, [:ball, :move])

        {:noreply, next_state}
    end
    

end



   
        
        