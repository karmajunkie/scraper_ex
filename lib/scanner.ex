defmodule Scanner do
  use GenServer

  #client interface
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # def handle_init(args) do
  #   {:ok, args}
  # end

  def handle_call({:add_page, url},  {from_pid, ref}, {scrapers, requester}) do
    requester.fetch(from_pid, url)

    {:reply, :ok, {scrapers, requester}}
  end

  def add_page(nil) do
    :error
  end

  def add_page(url) do
    GenServer.call(__MODULE__, {:add_page, url})
  end

end
