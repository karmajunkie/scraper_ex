defmodule ScannerTest do
  defmodule TestRequester do
    use GenServer

    def start_link(parent) do
      GenServer.start_link(__MODULE__, parent, name: __MODULE__)
    end

    def handle_init(parent) do
      {:ok, parent}
    end

    def handle_cast({:fetch, url}, parent_pid) do
      send(parent_pid, {:fetched, url})
      {:noreply, parent_pid}
    end
    def fetch(url) do
      GenServer.cast(__MODULE__, {:fetch, url})
    end
  end

  defmodule DisagreeableTestScraper do
    def valid_for_retrieval? do
      false
    end
  end

  defmodule TestScraper do
    use GenServer

    def start_link(parent) do
      GenServer.start_link(__MODULE__, %{parent: parent}, name: __MODULE__)
    end

    def valid_for_retrieval?(_url) do
      true
    end

    def handle_document(_document) do

    end
  end

  use ExUnit.Case, async: true

  setup do
    TestRequester.start_link(self)
    Scanner.start_link(%{requester: TestRequester, scrapers: [] })
    :ok
  end

  test "adding nil is an error" do
      assert :error=Scanner.add_page(nil)
  end

  test "adding a url sends it to the request engine" do
    test_url="http://foo.com"
    Scanner.add_page(test_url)
    assert_received {:fetched, ^test_url}, "first message not received"
  end

  test "adding a url a second time does not send it to the request engine a second time" do
    test_url="http://foo.com"
    Scanner.add_page(test_url)
    Scanner.add_page(test_url)
    assert_received {:fetched, ^test_url}, "first message not received"
    refute_received {:fetched, ^test_url}, "Second message received when it shouldn't be"
  end

  test "adding a scraper" do
    #how to have the scraper call back to test here?
    assert :ok=Scanner.add_scraper(TestScraper)

  end

end
