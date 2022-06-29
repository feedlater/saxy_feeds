defmodule SaxyFeeds.ParserState do
  @moduledoc """
  Struct and helper functions for tracking parser state.
  """

  alias __MODULE__
  alias SaxyFeeds.Feed

  defstruct capture_characters: false,
            character_buffer: [],
            feed: %Feed{},
            # Feed item currently being captured, if any.
            item: nil,
            # List of previously parsed feed items, in reverse order.
            items: [],
            path: [],
            structure_map: nil

  @doc """
  Add characters to the character buffer if character capture is enabled.
  """
  def add_characters(%ParserState{capture_characters: true} = state, characters) do
    %{state | character_buffer: [characters | state.character_buffer]}
  end

  def add_characters(%ParserState{} = state, _characters), do: state

  @doc """
  Clear the character buffer and start capturing characters.
  """
  def character_capture_start(%ParserState{} = state) do
    %{state | capture_characters: true, character_buffer: []}
  end

  @doc """
  Return captured characters and stop capturing characters.
  """
  def character_capture_end(%ParserState{} = state) do
    {state.character_buffer |> Enum.reverse() |> Enum.join(""),
     %{state | capture_characters: false, character_buffer: []}}
  end

  @doc """
  Shift key unto the path.

  Path is kept in reverse order, so the deepest level is at position 0
  of the list.
  """
  def path_shift(%ParserState{} = state, key) do
    %{state | path: [key | state.path]}
  end

  @doc """
  Unshift key unto the path.

  Path is kept in reverse order, so the deepest level is at position 0
  of the list.
  """
  def path_unshift(%ParserState{path: []} = state), do: state

  def path_unshift(%ParserState{} = state) do
    [_removed | path] = state.path
    %{state | path: path}
  end
end
