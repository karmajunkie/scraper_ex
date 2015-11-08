defmodule ScannerTest do
  defmodule TestRequester do
    use GenServer

    def start_link(parent) do
      GenServer.start_link(__MODULE__, parent, name: __MODULE__)
    end

    def handle_init(parent) do
      {:ok, parent}
    end

    def fetch(pid, url) do
      send(pid, {:fetched, url})
    end
  end

  defmodule AgreeableTestScraper do
    def valid_for_retrieval? do
      false
    end
  end
  defmodule TestScraper do
    def valid_for_retrieval?(_url) do
      true
    end

    def handle_document(_document) do

    end
  end

  use ExUnit.Case

  setup do
    TestRequester.start_link(self)
    Scanner.start_link({[TestScraper], TestRequester })
    :ok
  end

  test "adding nothing adds... nothing" do
      assert :error=Scanner.add_page(nil)
  end

  test "adding a url sends it to the scrape queue" do
    test_url="http://foo.com"
    Scanner.add_page(test_url)
    assert_received {:fetched, ^test_url}, "first message not received"
  end

  test "adding a url a second time does not scrape it again" do
    test_url="http://foo.com"
    Scanner.add_page(test_url)
    Scanner.add_page(test_url)
    assert_received {:fetched, ^test_url}, "first message not received"
    refute_received {:fetched, ^test_url}, "Second message received when it shouldn't be"
  end

end
