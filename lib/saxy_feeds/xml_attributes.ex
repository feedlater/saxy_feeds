defmodule SaxyFeeds.XmlAttributes do
  @moduledoc """
  Helper functions for XML attributes.

  Saxy returns XML element attributes as a keyword-list like structure
  with string keys.

  Since functions like Keywords.get/3 expect atom keys, here we
  re-implement a few of them with string keys instead.
  """

  @doc """
  Gets the value under the given `key`.

  Returns the default value if `key` does not exist
  (`nil` if no default value is provided).

  If duplicate entries exist, it returns the first one.

  ## Examples

      iex> XmlAttributes.get([], "a")
      nil

      iex> XmlAttributes.get([{"a", 1}], "a")
      1

      iex> XmlAttributes.get([{"a", 1}], "b")
      nil

      iex> XmlAttributes.get([{"a", 1}], "b", 3)
      3

  With duplicate keys:

      iex> XmlAttributes.get([{"a", 1}, {"a", 2}], "a", 3)
      1

      iex> XmlAttributes.get([{"a", 1}, {"a", 2}], "b", 3)
      3
  """
  def get(attrs, key, default \\ nil) when is_list(attrs) do
    case :lists.keyfind(key, 1, attrs) do
      {^key, value} -> value
      false -> default
    end
  end
end
