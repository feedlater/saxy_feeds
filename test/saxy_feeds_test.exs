defmodule SaxyFeedsTest do
  use ExUnit.Case, async: true

  describe "parse_string/1" do
    test "parses a 800kB Atom 1.0 feed" do
      {:ok, xml_string} = File.read("test/support/fixtures/feeds/atom-1.0-elixir.xml")

      {:ok, feed} = SaxyFeeds.parse_string(xml_string)

      assert feed.id == "http://elixir-lang.org"
      assert feed.title == "Elixir Lang"
      assert feed.feed_url == "http://elixir-lang.org/atom.xml"
      assert feed.home_page_url == "http://elixir-lang.org"

      assert length(feed.items) == 49

      item = Enum.at(feed.items, 0)

      assert item.id == "/blog/2021/12/03/elixir-v1-13-0-released"
      assert item.title == "Elixir v1.13 released" 
      assert item.url == "http://elixir-lang.org/blog/2021/12/03/elixir-v1-13-0-released/"
      assert String.contains?(item.content_html, "asciinema</a> snippets. You may need")
      assert item.date_modified == ~U[2021-12-03 00:00:00Z]
    end

    test "parses a minimal RSS 2.0 feed" do
      {:ok, xml_string} = File.read("test/support/fixtures/feeds/rss-2.0-minimal.xml")

      {:ok, feed} = SaxyFeeds.parse_string(xml_string)

      assert feed.title == "Blog posts on hex.pm"
      assert feed.language == "en"
      assert feed.description == "Blog posts on hex.pm"
      assert feed.home_page_url == "https://hex.pm/blog"

      assert length(feed.items) == 3

      item = Enum.at(feed.items, 0)
      assert item.title == "Hex v1.0 released and the future of Hex"
      assert String.contains?(item.description, "again with no major changes.")
      assert item.date_published == ~U[2021-12-13 00:00:00Z]
    end

    test "parses a complex RSS 2.0 feed" do
      {:ok, xml_string} = File.read("test/support/fixtures/feeds/rss-2.0-complex.xml")

      {:ok, feed} = SaxyFeeds.parse_string(xml_string)

      assert feed.title == "Complex RSS fixture"
      assert feed.language == "en-US"

      assert feed.description ==
               "News feed and read it later app, built by Mikkel Högh and his merry men."

      assert feed.home_page_url == "https://www.feedlater.test"

      assert length(feed.items) == 1

      item = Enum.at(feed.items, 0)
      assert item.id == "https://www.feedlater.test/?p=67968"
      assert item.url == "https://www.feedlater.test/cast/episode-242-the-ipad-mini-small-wonder/"
      assert item.title == "FeedlaterCast, Episode 242 – The iPad mini: Small Wonder"
      assert item.date_published == ~U[2021-09-29 16:52:03Z]
      assert String.contains?(item.description, "look at Apple’s new iPad lineup")

      assert String.contains?(
               item.content_html,
               "<p id=\"p2\">It’s not like Apple doesn’t have enough money already.</p>"
             )
    end
  end
end
