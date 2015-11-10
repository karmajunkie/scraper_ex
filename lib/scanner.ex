defmodule Scanner do
  use GenServer

  #client interface
  def add_page(nil) do
    :error
  end

  def add_page(url) do
    GenServer.call(__MODULE__, {:add_page, url})
  end

  def add_scraper(scraper) do
    GenServer.call(__MODULE__, {:add_scraper, scraper})
  end

  #GenServer impl
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args \\ %{}) do
    {:ok,
     args |> Map.put(:table, %{})
    }
  end

  def handle_call({:add_scraper,  scraper},_, state) do
    {:reply,
     :ok,
     state |> Map.update(:scrapers, [], fn s ->  (s  ++ [scraper]) end)
    } 
  end

  # def handle_call({:add_page, url},  _, state) when is_nil(state[:table][url]) do 
    
  #   state.requester.fetch(url)
  #   new_state = Map.put(state, :table, Map.update(state.table, url, true, fn _ -> true end) )
  #   {:reply, :ok, new_state}
  # end

  def handle_call({:add_page, url},  _, state) do
    elm = state.table[url]
    if elm == nil do
      state.requester.fetch(url)
      state=Map.put(state, :table, Map.update(state.table, url, true, fn _ -> true end) )
    end

    {:reply, :ok, state}
  end
end
