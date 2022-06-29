defmodule SaxyFeeds do
  @moduledoc """
  Documentation for `SaxyFeeds`.
  """

  alias SaxyFeeds.EventHandler
  alias SaxyFeeds.ParserState

  def parse_string(xml_string) do
    case Saxy.parse_string(xml_string, EventHandler, %ParserState{}) do
      {:ok, feed} -> {:ok, feed}
      {:halt, reason, _rest} -> {:error, reason}
    end
  end
end
