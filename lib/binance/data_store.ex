defmodule Mamba.DataStore do  
    use Agent

    def start_link(opts) do  
        Agent.start_link(fn -> opts end, [name: __MODULE__])
    end 
    
    def put(value, key) do
        Agent.update(__MODULE__, &Map.put(&1, key, value))
    end
    
    def get(key) do  
        Agent.get(__MODULE__, &Map.get(&1, key))  
    end

    def get_all() do
        Agent.get(__MODULE__, fn map -> map end)
    end
    
    def delete_one(pid, key) do
        Agent.update(pid, &Map.delete(&1, key))
    end

end 