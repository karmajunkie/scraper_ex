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
     args |> Map.put(:table, :ets.new(:urls, [:set, :protected]))
    }
  end

  def handle_call({:add_scraper,  scraper},_, state) do
    {:ok,
     state |> Map.put(scrapers: Enum.concat(state.scrapers, scraper))
    }
  end

  def handle_call({:add_page, url},  _, state) do
    elm = :ets.lookup(state.table, url)
    if Enum.empty?(elm) do
      state.requester.fetch(url)
      :ets.insert(state.table, {url, true})
    end

    {:reply, :ok, state}
  end
end
