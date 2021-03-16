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
        what_i_have = "usdt"
        top_data_results = calcOne(top_data, what_i_have)
        middle_data_results = calcOne(middle_data, top_data_results["new_what_i_have"])
        bottom_data_results = calcOne(bottom_data, middle_data_results["new_what_i_have"])

        profit = top_data_results["calcResults"] * middle_data_results["calcResults"] * bottom_data_results["calcResults"] 

        IO.inspect(%{
            "top_data_results" => %{"calcResults" => top_data_results["calcResults"], "top_data" => top_data},
            "middle_data_results" => %{"calcResults" => middle_data_results["calcResults"], "middle_data" => middle_data},
            "bottom_data_results" => %{"calcResults" => bottom_data_results["calcResults"], "bottom_data" => bottom_data},
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
            true -> # Do Nothing
        end
        
    end

  end

#   {:ok, pid} = Binance.start_link {{"btc", "usdt"}, {"bnb", "btc"}, {"bnb", "usdt"}}, []
#   {:ok, pid} = Binance.start_link {{"eth", "usdt"}, {"bnb", "eth"}, {"bnb", "usdt"}}, []
#   {:ok, pid} = Binance.start_link {{"usdt", "dai"}, {"bnb", "dai"}, {"bnb", "usdt"}}, []
#   {:ok, pid} = Binance.start_link {{"bnb", "usdt"}, {"bnb", "btc"}, {"btc", "usdt"}}, []
#   {:ok, pid} = Binance.start_link {{"ltc", "btc"}, {"bnb", "btc"}, {"ltc", "bnb"}}, []

x = %{                             
    "bottom_data_results" => %{
      "bottom_data" => %{
        "baseAsset" => "bnb",
        "data" => %{
          "A" => "3.03300000",
          "B" => "9.61000000",
          "a" => "255.90800000",
          "b" => "255.88940000",
          "s" => "BNBUSDT",
          "u" => 3148018662
        },
        "quoteAsset" => "usdt",
        "stream" => "bnbusdt@bookTicker"
      },
      "calcResults" => 255.8894
    },
    "middle_data_results" => %{
      "calcResults" => 217.90290246666086,
      "middle_data" => %{
        "baseAsset" => "bnb",
        "data" => %{
          "A" => "7.39000000",
          "B" => "3.95000000",
          "a" => "0.00458920",
          "b" => "0.00458870",
          "s" => "BNBBTC",
          "u" => 1516125238
        },
        "quoteAsset" => "btc",
        "stream" => "bnbbtc@bookTicker"
      }
    },
    "profit" => "0.9998983760599196%",
    "top_data_results" => %{
      "calcResults" => 1.7932488127347923e-5,
      "top_data" => %{
        "baseAsset" => "btc",
        "data" => %{
          "A" => "2.42045700",
          "B" => "0.35441900",
          "a" => "55764.71000000",
          "b" => "55764.70000000",
          "s" => "BTCUSDT",
          "u" => 9542094364
        },
        "quoteAsset" => "usdt",
        "stream" => "btcusdt@bookTicker"
      }
    }
  }
  