defmodule Mamba.Binance do
    use WebSockex
    alias Mamba.Binance.TradeEvents

   _stream_endpoint = "wss://stream.binance.com:9443/ws/"
  
    def start_link({symbol_one, symbol_two, symbol_three} = symbols, state) do
        #   WebSockex.start_link("wss://stream.binance.com:9443/ws/#{symbol}@bookTicker", __MODULE__, state)
        WebSockex.start_link("wss://stream.binance.com:9443/stream?streams=#{symbol_one}@bookTicker/#{symbol_two}@bookTicker/#{symbol_three}@bookTicker", __MODULE__, state)
    end
  
    def handle_frame({type, msg}, state) do

        case Jason.decode(msg) do
            {:ok, event} -> IO.inspect event #handle_cast(event, state)
            {:error, _} -> throw("Error processing the message: #{msg}")
        end

        {:ok, state}

    end
  
    def handle_cast(%{"e" => "trade"} = event, state) do
      
        
        trade_event = %TradeEvents{
            :event_type => event["e"],
            :event_time => event["E"],
            :symbol => event["s"],
            :trade_id => event["t"],
            :price => event["p"],
            :quantity => event["q"],
            :buyer_order_id => event["b"],
            :seller_order_id => event["a"],
            :trade_time => event["T"],
            :buyer_the_market_maker => event["m"],
            :ignore => event["M"]
        }

        IO.inspect(trade_event, label: "Trade Event Received: ")

    end

    def calcArb(event) do
        
    end

  end