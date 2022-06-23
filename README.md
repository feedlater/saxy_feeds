# Saxy Feeds

Fast and efficient Atom and RSS feed parser powered by [Saxy][].

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `saxy_feeds` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:saxy_feeds, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/saxy_feeds>.

## Design principles

Saxy Feeds is intended to be able to parse feeds from all over the
Internet, not all of which might be completely up to specification.

Thus, it aims to follow Postel’s Law, formulated as:

> be conservative in what you output, be liberal in what you parse

Since Saxy Feeds uses a SAX parser (as opposed to a DOM parser), it
favours speed and efficiency, rather than absolute correctness. It
ignores DTDs and XSDs and parses XML in chunks rather than the whole
document at once.

It also expects the input document to be UTF-8. If you need to parse
feeds in other charsets, you will need to transform them to UTF-8
yourself before passing them to Saxy Feeds.

[saxy]: https://hex.pm/packages/saxy
