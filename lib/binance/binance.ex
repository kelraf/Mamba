defmodule Mamba.Binance do
    use WebSockex
    alias Mamba.DataStoreManager
    alias Mamba.DataStore

   _stream_endpoint = "wss://stream.binance.com:9443/ws/"
  
    def start_link({{baseAsset1, quoteAsset1}, {baseAsset2, quoteAsset2}, {baseAsset3, quoteAsset3}} = symbols, state) do
        #   WebSockex.start_link("wss://stream.binance.com:9443/ws/#{symbol}@bookTicker", __MODULE__, state)
        case DataStoreManager.assignSymbols(symbols) do
            {:ok, _message} ->
                WebSockex.start_link("wss://stream.binance.com:9443/stream?streams=#{baseAsset1}#{quoteAsset1}@bookTicker/#{baseAsset2}#{quoteAsset2}@bookTicker/#{baseAsset3}#{quoteAsset3}@bookTicker", __MODULE__, state)
            {:error, _} ->
                IO.puts "An Error Occured."
        end
    end
  
    def handle_frame({_type, msg}, state) do

        case Jason.decode(msg) do
            {:ok, event} -> assignSteamToDataStore(event)
            {:error, _} -> throw("Error processing the message: #{msg}")
        end

        {:ok, state}

    end

    defp assignSteamToDataStore(event) do

        cond do

            event["stream"] == DataStore.get("top_data")["stream"] -> 

                top_data = DataStore.get("top_data")
                baseAsset = top_data["baseAsset"]
                quoteAsset = top_data["quoteAsset"]

                event
                |> Map.put("baseAsset", baseAsset)
                |> Map.put("quoteAsset", quoteAsset)
                |> DataStore.put("top_data") 
                # IO.inspect %{"symbols" => event["stream"], "data_level" => "Top Data"}

            event["stream"] == DataStore.get("middle_data")["stream"] -> 

                middle_data = DataStore.get("middle_data")
                baseAsset = middle_data["baseAsset"]
                quoteAsset = middle_data["quoteAsset"]

                event
                |> Map.put("baseAsset", baseAsset)
                |> Map.put("quoteAsset", quoteAsset)
                |> DataStore.put("middle_data")
                # IO.inspect %{"symbols" => event["stream"], "data_level" => "Middle Data"}

            event["stream"] == DataStore.get("bottom_data")["stream"] -> 

                bottom_data = DataStore.get("bottom_data")
                baseAsset = bottom_data["baseAsset"]
                quoteAsset = bottom_data["quoteAsset"]

                event
                |> Map.put("baseAsset", baseAsset)
                |> Map.put("quoteAsset", quoteAsset)
                |> DataStore.put("bottom_data")
                # IO.inspect %{"symbols" => event["stream"], "data_level" => "Bottom Data"}

        end

    end

  end