defmodule SaxyFeeds.Formats.Rss2 do
  @moduledoc """
  Parser configuration for RSS 2.0 feeds.
  """

  # String-keys for sub-elements, atom keys for metadata.
  @structure_map %{
    "channel" => %{
      "title" => %{
        entity: :feed,
        field: :title,
        has_text_content: true
      },
      "description" => %{
        entity: :feed,
        field: :description,
        has_text_content: true
      },
      "link" => %{
        entity: :feed,
        field: :home_page_url,
        has_text_content: true
      },
      "language" => %{
        entity: :feed,
        field: :language,
        has_text_content: true
      },
      "item" => %{
        "guid" => %{
          entity: :item,
          field: :id,
          has_text_content: true
        },
        "title" => %{
          entity: :item,
          field: :title,
          has_text_content: true
        },
        "description" => %{
          entity: :item,
          field: :description,
          has_text_content: true
        },
        "link" => %{
          entity: :item,
          field: :url,
          has_text_content: true
        },
        "pubDate" => %{
          entity: :item,
          field: :date_published,
          has_text_content: true
        },
        "content:encoded" => %{
          entity: :item,
          field: :content_html,
          has_text_content: true
        },
        has_children: true
      },
      has_children: true
    }
  }

  @doc """
  Get event handler structure map for RSS 2.0.
  """
  def get_structure_map, do: @structure_map
end
