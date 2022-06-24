defmodule SaxyFeeds.Feed do
  @moduledoc """
  Struct for feed data.
  """

  defstruct type: nil,
            version: nil,
            title: nil,
            home_page_url: nil,
            feed_url: nil,
            description: nil,
            user_comment: nil,
            next_url: nil,
            icon: nil,
            favicon: nil,
            authors: [],
            language: nil,
            expired: false,
            hubs: [],
            items: []
end
