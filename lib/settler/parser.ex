defmodule Settler.Parser do
  @moduledoc """
  Implements parsing functions and combinators for
  extracting elements from ASCII STL files and binary
  strings and calculating details about the objects
  defined.

  Because the `defcombinatorp` macro does not produce public functions,
  docstrings are replaced with simple comments to avoid compiler
  warnings about discarded `@doc` annotations on private functions.
  """

  import NimbleParsec

  @name_chars [?a..?z, ?A..?Z, ?0..?9]
  @float_chars [?0..?9, ?., ?e, ?E, ?-, ?+]

  # Defines a combinator to parse a line for three floating point
  #numbers.
  defcombinatorp(
    :coordinate,
    duplicate(eventually(ascii_string(@float_chars, min: 1)), 3),
    inline: true
  )

  # Defines a combinator to parse a line for the starting indicator
  # of an STL object, the `solid ` keyword with a potentially arbitrary
  # amount of whitespace before the keyword, followed by at least a single
  # whitespace character, followed by an optional string identifier
  # serving as the name of the object, followed by potentially arbitrary
  # additional whitespace.

  # The potential whitespace prior to the `solid ` keyword is explicitly
  # parsed to avoid the parser mistaking the corresponding `endsolid` for
  # a `solid ` line by simply skipping all preceding characters in the line.
  defcombinatorp(
    :solid,
    ignore(optional(ascii_string([32, ?\t, ?\n, ?\r], min: 1)))
    |> ignore(string("solid "))
    |> optional(eventually(tag(ascii_string(@name_chars, min: 1), :name))),
    inline: true
  )

  # Defines a combinator for matching the end of the STL document and
  # injecting an indicator for the `File.Stream` function to match on and
  # trigger the exit of the stream/document parsing.
  defcombinatorp(
    :endsolid,
    eventually(string("endsolid"))
    |> replace(:eof)
    |> optional(eventually(tag(ascii_string(@name_chars, min: 1), :name))),
    inline: true
  )

  # Defines a combinator for matching the `facet normal` line of an STL
  # triangle facet and tagging the values of the normal vector for extraction
  # by parser.
  defcombinatorp(
    :facet,
    ignore(eventually(string("facet normal")))
    |> tag(parsec(:coordinate), :normal),
    inline: true
  )

  # Defines a combinator for signifying the end of a facet (to be ignored
  # when constructing the STL struct).
  defcombinatorp(
    :endfacet,
    eventually(string("endfacet")),
    inline: true
  )

  # Defines a combinator for signifying the beginning of a facet loop
  # of vertex entries (to be ignored when constructing the STL struct).
  defcombinatorp(
    :loop,
    eventually(string("outer loop")),
    inline: true
  )

  # Defines a combinator for signifying the end of a facet loop of
  # vertex entries (to be ignored when constructing the STL struct).
  defcombinatorp(
    :endloop,
    eventually(string("endloop")),
    inline: true
  )

  # Defines a combinator for parsing the `vertex` lines from an STL
  # document and extracting the coordinates of the vertex.
  defcombinatorp(
    :vertex,
    ignore(eventually(string("vertex")))
    |> tag(parsec(:coordinate), :vertex),
    inline: true
  )

  @doc """
  Defines a single entrypoint parser/combinator to read each line of
  an STL document and output a `{:ok, _, _, _, _, _}` tuple for any
  potentially valid line according to the STL ASCII specification.
  """
  defparsec(
    :stl,
    choice([
      parsec(:solid),
      parsec(:endsolid),
      parsec(:facet),
      parsec(:endfacet),
      parsec(:loop),
      parsec(:endloop),
      parsec(:vertex)
    ]),
    inline: true
  )
end
