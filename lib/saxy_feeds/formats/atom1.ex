defmodule SaxyFeeds.Formats.Atom1 do
  @moduledoc """
  Parser configuration for Atom 1.0 feeds.
  """

  alias SaxyFeeds.{EventHandler, ParserState, XmlAttributes}

  require Logger

  # String-keys for sub-elements, atom keys for metadata.
  @structure_map %{
    "feed" => %{
      "id" => %{
        entity: :feed,
        field: :id,
        has_text_content: true
      },
      "title" => %{
        entity: :feed,
        field: :title,
        has_text_content: true
      },
      "subtitle" => %{
        entity: :feed,
        field: :description,
        has_text_content: true
      },
      "link" => %{
        entity: :feed,
        field: :home_page_url,
        save_handler: &__MODULE__.save_feed_link/3
      },
      "language" => %{
        entity: :feed,
        field: :language,
        has_text_content: true
      },
      "entry" => %{
        "id" => %{
          entity: :item,
          field: :id,
          has_text_content: true
        },
        "title" => %{
          entity: :item,
          field: :title,
          has_text_content: true
        },
        "summary" => %{
          entity: :item,
          field: :summary,
          has_text_content: true
        },
        "link" => %{
          entity: :item,
          field: :url,
          save_handler: &__MODULE__.save_entry_link/3
        },
        "published" => %{
          entity: :item,
          field: :date_published,
          has_text_content: true,
          save_handler: &__MODULE__.save_rfc3339_timestamp/3
        },
        "updated" => %{
          entity: :item,
          field: :date_modified,
          has_text_content: true,
          save_handler: &__MODULE__.save_rfc3339_timestamp/3
        },
        "content" => %{
          entity: :item,
          has_text_content: true,
          save_handler: &__MODULE__.save_content/3
        },
        contains_entity: :item,
        has_children: true
      },
      has_children: true
    }
  }

  @doc """
  Get event handler structure map for Atom 1.0.
  """
  def get_structure_map, do: @structure_map

  @doc """
  Save handler for content tag on Atom entries.

  Saves it under content_text or content_html depending on type.
  """
  def save_content(%ParserState{} = state, mapping, content) do
    attrs = Map.get(state.attributes, state.path_string, [])
    type = XmlAttributes.get(attrs, "type")

    if type == "html" or type == "xhtml" do
      EventHandler.update_entity_with_mapped_field(
        state,
        Map.put(mapping, :field, :content_html),
        content
      )
    else
      EventHandler.update_entity_with_mapped_field(
        state,
        Map.put(mapping, :field, :content_text),
        content
      )
    end
  end

  @doc """
  Save handler for link tag on Atom entries.

  Different destinations based on href and type.
  """
  def save_entry_link(%ParserState{} = state, mapping, _content) do
    attrs = Map.get(state.attributes, state.path_string, [])
    href = XmlAttributes.get(attrs, "href")

    # "alternate" is the default rel as per RFC 4287
    # https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.7.2
    rel = XmlAttributes.get(attrs, "rel", "alternate")

    if is_binary(href) and byte_size(href) > 0 do
      if rel == "alternate" or rel == "self" do
        EventHandler.update_entity_with_mapped_field(
          state,
          mapping,
          href
        )
      else
        state
      end
    else
      state
    end
  end

  @doc """
  Save handler for link tag on Atom feed.

  Different destinations based on href and type.
  """
  def save_feed_link(%ParserState{} = state, mapping, _content) do
    attrs = Map.get(state.attributes, state.path_string, [])
    href = XmlAttributes.get(attrs, "href")

    # "alternate" is the default rel as per RFC 4287
    # https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.7.2
    rel = XmlAttributes.get(attrs, "rel", "alternate")

    if is_binary(href) and byte_size(href) > 0 do
      case rel do
        "alternate" ->
          EventHandler.update_entity_with_mapped_field(
            state,
            Map.put(mapping, :field, :home_page_url),
            href
          )

        "self" ->
          EventHandler.update_entity_with_mapped_field(
            state,
            Map.put(mapping, :field, :feed_url),
            href
          )

        _other ->
          state
      end
    else
      state
    end
  end

  @doc """
  Save handler for RFC3339 timestamps.

  Parses the RFC3339 format into an Elixir DateTime struct.
  """
  def save_rfc3339_timestamp(%ParserState{} = state, mapping, content) do
    case Timex.parse(content, "{RFC3339}") do
      {:ok, date_time} ->
        EventHandler.update_entity_with_mapped_field(state, mapping, date_time)

      {:error, term} ->
        Logger.warning(
          "String `#{content}` could not be parsed as RFC3339 timestamp: `#{inspect(term)}`."
        )

        state
    end
  end
end
