defmodule SaxyFeeds.Feed.Item do
  @moduledoc """
  Struct for feed items.
  """

  defstruct id: nil,
            url: nil,
            external_url: nil,
            title: nil,
            content_html: nil,
            content_text: nil,
            summary: nil,
            image: nil,
            banner_image: nil,
            date_published: nil,
            date_modified: nil,
            authors: [],
            tags: [],
            attachments: [],
            language: nil
end
