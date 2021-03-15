defmodule Mamba.DataStoreManager do

    alias Mamba.DataStore

    def mapStructure() do
        %{
            "arb_symbols" => "",
            "top_data" => %{      
                "data" => %{
                  "A" => "0",
                  "B" => "0",
                  "a" => "0",
                  "b" => "0",
                  "s" => "",
                  "u" => 0
                },
                "stream" => ""
            },
            "middle_data" => %{      
                "data" => %{
                  "A" => "0",
                  "B" => "0",
                  "a" => "0",
                  "b" => "0",
                  "s" => "",
                  "u" => 0
                },
                "stream" => ""
            },
            "bottom_data" => %{      
                "data" => %{
                  "A" => "0",
                  "B" => "0",
                  "a" => "0",
                  "b" => "0",
                  "s" => "",
                  "u" => 0
                },
                "stream" => ""
            }
              
        }
    end

    def assignSymbols({{baseAsset1, quoteAsset1}, {baseAsset2, quoteAsset2}, {baseAsset3, quoteAsset3}} = symbols) do

        DataStore.put("#{baseAsset1}#{quoteAsset1}-#{baseAsset2}#{quoteAsset2}-#{baseAsset3}#{quoteAsset3}", "arb_symbols") 

        case matchStoredData(symbols) do

            {:ok, data} ->

                {top_data, middle_data, bottom_data} = data

                DataStore.put(top_data, "top_data")
                DataStore.put(middle_data, "middle_data")
                DataStore.put(bottom_data, "bottom_data")

                {:ok, "Success"}

            {:error, message} ->

                {:error, message}

        end

    end

    defp matchStoredData({{baseAsset1, quoteAsset1}, {baseAsset2, quoteAsset2}, {baseAsset3, quoteAsset3}} = symbols) do

        %{"top_data" => top_data, "middle_data" => middle_data, "bottom_data" => bottom_data} = DataStore.get_all

        top_data = 
            top_data
            |> Map.put("stream", "#{baseAsset1}#{quoteAsset1}@bookTicker")
            |> Map.put("baseAsset", baseAsset1)
            |> Map.put("quoteAsset", quoteAsset1)

        middle_data = 
            middle_data
            |> Map.put("stream", "#{baseAsset2}#{quoteAsset2}@bookTicker")
            |> Map.put("baseAsset", baseAsset2)
            |> Map.put("quoteAsset", quoteAsset2)

        bottom_data = 
            bottom_data
            |> Map.put("stream", "#{baseAsset3}#{quoteAsset3}@bookTicker")
            |> Map.put("baseAsset", baseAsset3)
            |> Map.put("quoteAsset", quoteAsset3)

        {:ok, {top_data, middle_data, bottom_data}}

    end

    defp matchStoredData(_) do

        {:error, "Error"}

    end

end
