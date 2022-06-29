defmodule SaxyFeeds.ParserStateTest do
  use ExUnit.Case, async: true

  alias SaxyFeeds.ParserState

  doctest ParserState

  describe "add_characters/2" do
    test "add characters to buffer if capture is enabled" do
      state =
        %ParserState{capture_characters: true}
        |> ParserState.add_characters("Max")
        |> ParserState.add_characters("Moritz")

      # Character buffer is in reverse order, by design.
      assert state.character_buffer == ["Moritz", "Max"]
    end

    test "does nothing if capture is disabled" do
      state =
        %ParserState{capture_characters: false}
        |> ParserState.add_characters("Moritz")
        |> ParserState.add_characters("Max")

      assert state.character_buffer == []
    end
  end

  describe "character_capture_start/1" do
    test "enables character capture" do
      state =
        %ParserState{capture_characters: false}
        |> ParserState.character_capture_start()

      assert state.capture_characters == true
    end

    test "clears the character buffer" do
      state =
        %ParserState{character_buffer: ["Yarn", "Bundle"]}
        |> ParserState.character_capture_start()

      assert state.capture_characters == true
      assert state.character_buffer == []
    end
  end

  describe "character_capture_end/1" do
    test "combines multiple character groups as expected" do
      {text, state} =
        %ParserState{}
        |> ParserState.character_capture_start()
        |> ParserState.add_characters("Max")
        |> ParserState.add_characters(" und ")
        |> ParserState.add_characters("Moritz")
        |> ParserState.add_characters(", Zürich.")
        |> ParserState.character_capture_end()

      assert state.capture_characters == false
      assert state.character_buffer == []
      assert text == "Max und Moritz, Zürich."
    end
  end

  describe "path_shift/1" do
    test "adds elements to beginning of path" do
      state =
        %ParserState{}
        |> ParserState.path_shift("channel")
        |> ParserState.path_shift("item")

      assert state.path == ["item", "channel"]
    end
  end

  describe "path_unshift/1" do
    test "remove elements from beginning of path" do
      state = %ParserState{path: ["title", "item", "channel"]}

      state = ParserState.path_unshift(state)
      assert state.path == ["item", "channel"]

      state = ParserState.path_unshift(state)
      assert state.path == ["channel"]

      state = ParserState.path_unshift(state)
      assert state.path == []

      state = ParserState.path_unshift(state)
      assert state.path == []
    end
  end
end
