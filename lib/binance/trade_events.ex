defmodule Mamba.Binance.TradeEvents do
    
    defstruct [
        :event_type,
        :event_time,
        :symbol,
        :trade_id,
        :price,
        :quantity,
        :buyer_order_id,
        :seller_order_id,
        :trade_time,
        :buyer_the_market_maker,
        :ignore
    ]

end