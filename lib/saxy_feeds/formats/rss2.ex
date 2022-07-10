defmodule SaxyFeeds.Formats.Rss2 do
  @moduledoc """
  Parser configuration for RSS 2.0 feeds.
  """

  alias SaxyFeeds.{EventHandler, ParserState}

  require Logger

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
          field: :summary,
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
          has_text_content: true,
          save_handler: &__MODULE__.save_rss_timestamp/3
        },
        "content:encoded" => %{
          entity: :item,
          field: :content_html,
          has_text_content: true
        },
        contains_entity: :item,
        has_children: true
      },
      has_children: true
    }
  }

  @doc """
  Get event handler structure map for RSS 2.0.
  """
  def get_structure_map, do: @structure_map

  @doc """
  Save handler for RSS timestamps.

  Parses the nasty old RSS timestamp format into an Elixir DateTime struct.
  """
  def save_rss_timestamp(%ParserState{} = state, mapping, content) do
    case Timex.parse(content, "{RFC1123}") do
      {:ok, date_time} ->
        EventHandler.update_entity_with_mapped_field(state, mapping, date_time)

      {:error, term} ->
        Logger.warning(
          "String `#{content}` could not be parsed as RSS timestamp: `#{inspect(term)}`."
        )

        state
    end
  end
end
