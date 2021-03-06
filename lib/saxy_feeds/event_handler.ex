defmodule SaxyFeeds.EventHandler do
  @moduledoc """
  Main Saxy event handler.
  """

  alias SaxyFeeds.Formats.{Atom1, Rss2}
  alias SaxyFeeds.Feed.Item
  alias SaxyFeeds.{ParserState, XmlAttributes}

  require Logger

  @behaviour Saxy.Handler

  @impl true
  def handle_event(:start_document, _prolog, %ParserState{} = state) do
    # For now we assume we need nothing from the XML prologue.
    {:ok, state}
  end

  @impl true
  def handle_event(:end_document, _data, %ParserState{} = state) do
    {:ok, %{state.feed | items: Enum.reverse(state.items)}}
  end

  # Root element handler for Atom 1.0.
  @impl true
  def handle_event(:start_element, {"feed", attrs}, %ParserState{path: []} = state) do
    case XmlAttributes.get(attrs, "xmlns") do
      "http://www.w3.org/2005/Atom" ->
        {:ok,
         %{
           state
           | format: Atom1,
             structure_map: Atom1.get_structure_map()
         }
         |> ParserState.path_shift("feed")}

      rejected ->
        {:halt, "Encountered unsupported feed XML namespace #{rejected}."}
    end
  end

  # Root element handler for RSS 2.0.
  @impl true
  def handle_event(:start_element, {"rss", attrs}, %ParserState{path: []} = state) do
    case XmlAttributes.get(attrs, "version") do
      "2.0" ->
        {:ok, %{state | format: Rss2, structure_map: Rss2.get_structure_map()}}

      rejected ->
        {:halt, "Encountered unsupported RSS version #{rejected}."}
    end
  end

  @impl true
  def handle_event(:start_element, {elem, attrs}, %ParserState{} = state) do
    state = ParserState.path_shift(state, elem)

    mapping = get_mapping_for_path(state)

    if is_map(mapping) do
      {:ok,
       state
       |> maybe_create_new_entity(mapping)
       |> maybe_capture_attributes(attrs)
       |> maybe_start_character_capture(mapping)}
    else
      Logger.warning("Found unexpected element at path `#{debug_path(state)}`")
      {:ok, state}
    end
  end

  @impl true
  def handle_event(:end_element, elem, %ParserState{path: [expected | _tail]})
      when elem != expected do
    {:halt, "Element end mismatch trying to close element: `#{elem}`, we expected `#{expected}`."}
  end

  @impl true
  def handle_event(:end_element, _elem, %ParserState{capture_characters: true} = state) do
    mapping = get_mapping_for_path(state)

    {content, state} = ParserState.character_capture_end(state)

    if content != "" do
      {:ok,
       state
       |> save_element_content(mapping, content)
       |> maybe_drop_attributes()
       |> ParserState.path_unshift()}
    else
      {:ok,
       state
       |> maybe_drop_attributes()
       |> ParserState.path_unshift()}
    end
  end

  @impl true
  def handle_event(:end_element, _elem, %ParserState{} = state) do
    mapping = get_mapping_for_path(state)

    {:ok,
     state
     |> maybe_run_save_handler(mapping)
     |> maybe_finalize_entity(mapping)
     |> ParserState.path_unshift()}
  end

  @impl true
  def handle_event(:characters, _chars, %ParserState{capture_characters: false} = state) do
    # Not capturing characters at this position, ignore.
    {:ok, state}
  end

  @impl true
  def handle_event(:characters, chars, %ParserState{capture_characters: true} = state) do
    # Skip empty or white-space only nodes.
    if chars == "" or String.trim(chars) == "" do
      {:ok, state}
    else
      {:ok, ParserState.add_characters(state, chars)}
    end
  end

  @doc """
  Save element content into the state as defined by the mapping.

  Checks for a custom save handler before saving the value untransformed.
  """
  def save_element_content(%ParserState{} = state, mapping, content) do
    if is_nil(Map.get(mapping, :save_handler)) do
      update_entity_with_mapped_field(state, mapping, content)
    else
      mapping.save_handler.(state, mapping, content)
    end
  end

  @doc """
  Given a field mapping and a value, update the field and entity
  specified with the given value.
  """
  def update_entity_with_mapped_field(%ParserState{} = state, mapping, value) do
    updated_entity =
      state
      |> Map.get(mapping.entity)
      |> Map.put(mapping.field, value)

    Map.put(state, mapping.entity, updated_entity)
  end

  defp debug_path(%ParserState{format: Rss2} = state) do
    Enum.join(["rss" | Enum.reverse(state.path)], ".")
  end

  defp debug_path(%ParserState{} = state), do: Enum.join(Enum.reverse(state.path), ".")

  defp get_mapping_for_path(%ParserState{path: path, structure_map: structure_map})
       when is_list(path) and path != [] do
    # state.path is kept in reverse order, so undo that first.
    path = Enum.reverse(path)

    get_in(structure_map, path)
  end

  defp get_mapping_for_path(_state), do: nil

  defp maybe_capture_attributes(%ParserState{} = state, []), do: state

  defp maybe_capture_attributes(%ParserState{} = state, attrs) do
    %{state | attributes: Map.put(state.attributes, state.path_string, attrs)}
  end

  defp maybe_create_new_entity(
         %ParserState{} = state,
         %{contains_entity: :item}
       ) do
    %{state | item: %Item{}}
  end

  defp maybe_create_new_entity(%ParserState{} = state, _elem), do: state

  defp maybe_drop_attributes(%ParserState{} = state) do
    %{state | attributes: Map.delete(state.attributes, state.path_string)}
  end

  defp maybe_finalize_entity(%ParserState{} = state, %{contains_entity: :item}) do
    %{state | items: [state.item | state.items], item: nil}
  end

  defp maybe_finalize_entity(%ParserState{} = state, _elem), do: state

  defp maybe_run_save_handler(%ParserState{} = state, %{save_handler: save_handler} = mapping) do
    save_handler.(state, mapping, nil)
  end

  defp maybe_run_save_handler(%ParserState{} = state, _mapping), do: state

  defp maybe_start_character_capture(%ParserState{} = state, %{has_text_content: true}) do
    ParserState.character_capture_start(state)
  end

  defp maybe_start_character_capture(%ParserState{} = state, %{}), do: state
end
