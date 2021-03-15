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
                calcArb()
                # IO.inspect %{"symbols" => event["stream"], "data_level" => "Top Data"}

            event["stream"] == DataStore.get("middle_data")["stream"] -> 

                middle_data = DataStore.get("middle_data")
                baseAsset = middle_data["baseAsset"]
                quoteAsset = middle_data["quoteAsset"]

                event
                |> Map.put("baseAsset", baseAsset)
                |> Map.put("quoteAsset", quoteAsset)
                |> DataStore.put("middle_data")
                calcArb()
                # IO.inspect %{"symbols" => event["stream"], "data_level" => "Middle Data"}

            event["stream"] == DataStore.get("bottom_data")["stream"] -> 

                bottom_data = DataStore.get("bottom_data")
                baseAsset = bottom_data["baseAsset"]
                quoteAsset = bottom_data["quoteAsset"]

                event
                |> Map.put("baseAsset", baseAsset)
                |> Map.put("quoteAsset", quoteAsset)
                |> DataStore.put("bottom_data")
                calcArb()
                # IO.inspect %{"symbols" => event["stream"], "data_level" => "Bottom Data"}

        end

    end

    defp calcArb() do
        
        %{"top_data" => top_data, "middle_data" => middle_data, "bottom_data" => bottom_data} = DataStore.get_all
        what_i_have = "ltc"
        top_data_results = calcOne(top_data, what_i_have)
        middle_data_results = calcOne(middle_data, top_data_results["new_what_i_have"])
        bottom_data_results = calcOne(bottom_data, middle_data_results["new_what_i_have"])

        profit = top_data_results["calcResults"] * middle_data_results["calcResults"] * bottom_data_results["calcResults"] 

        IO.inspect(%{
            "top_data_results" => top_data_results["calcResults"], 
            "middle_data_results" => middle_data_results["calcResults"],
            "bottom_data_results" => bottom_data_results["calcResults"], 
            "profit" => "#{profit}%"
        })

    end

    defp calcOne(%{"baseAsset" => baseAsset,
        "data" => %{
            "A" => _ask_quantity,
            "B" => _bid_quantity, 
            "a" => ask_price,
            "b" => bid_price,
            "s" => _symbol,
            "u" => _order_book_update_id
        },
        "quoteAsset" => quoteAsset,
        "stream" => _stream}, what_i_have) do

        cond do
            what_i_have == baseAsset ->
                {bid_price, _} = Float.parse(bid_price)
                %{"calcResults" => bid_price, "new_what_i_have" => quoteAsset}
                # {calcResults, new_what_i_have}
            what_i_have == quoteAsset ->
                {ask_price, _} = Float.parse(ask_price)
                %{"calcResults" => 1/ask_price, "new_what_i_have" => baseAsset}
                # {calcResults, new_what_i_have}
                
        end
        
    end

  end

#   {:ok, pid} = Binance.start_link {{"btc", "usdt"}, {"bnb", "btc"}, {"bnb", "usdt"}}, []
#   {:ok, pid} = Binance.start_link {{"ltc", "btc"}, {"bnb", "btc"}, {"ltc", "bnb"}}, []