# Settler

An Elixir library and command line tool for parsing and doing basic analysis of
ASCII STL files defining 3-dimensional objects.

## Design

Settler is intended to optimize for parsing large STL files (many triangles) by
streaming file contents one line at a time into the entrypoint parsing function.

Settler uses the NimbleParsec library to simplify pattern matching each line without
the need to explicitly recurse into the contents of a given line in order to extract
the desired details of the object.

While Settler currently expects input files to be properly formed, it is forgiving of the
variable amount of whitespace possible within the body of ASCII STL files according to the
STL file specification. It does require explicit whitespace in areas listed as "required"
according to the [spec](https://en.wikipedia.org/wiki/STL_(file_format)#ASCII_STL). This
means at least a single space character following the `solid` keyword (regardless of the
presence of a name), a space between the words `outer loop` and between `facet normal`.

Because the file stream builds the STL struct lazily as the file contents are traversed,
the analysis fields of the resulting object (number of triangles, total surface area) are
updated one at a time as each new triangle is added to the resulting object.

## Improvements

Because Settler is optimized for large files, it is likely less performant against
smaller files (that could easily fit entirely into memory on the parsing machine) than
if the parser functions decoded the entire file contents at once and performed the
analysis during the parsing process whenever possible.

One potential improvement in this regard would be to do complete parsing of the file
with NimbleParsec custom combinators and use NimbleParsec's `reduce/3` combinator to
traverse the output of the parsed file contents and perform the additional calculations
such as summing triangle count/surface area as well as computing the bounding box.

Alternatively, based on the amount of time needed to individually perform per-facet
calculations (surface area only at this time), these calculations could be post-poned until
parsing of the file contents were complete and then paralellized via `Task` operations.

## Installation
The primary interface to Settler (at the moment) is an escript command-line
utility. If not present in the source tarball, simply run the following commands
on a system with Elixir/Erlang installed to compile the library and build the
application binary. By default the `./settler` command utility will be built in
the root directory of the project.

Note: while escript files are compile binaries, they still require the underlying
BEAM runtime to be installed on the target system.

```
tar -xzf settler.tar.gz

cd ./settler

mix deps.get

mix compile

mix escript.build
```

## Usage

Once Settler is compiled and the escript binary is built, it can be run in one
of two ways:

### Library or IEx Console

To test the library directly from the IEx console, run the following commands
from the project root directory:

```
iex -S mix

iex> Settler.parse(<stl_string>)

or 

iex> Settler.parse(<stl_file_path>)
```

You can optionally send the output of the parse function to the formatter to
output a string representation of the details analyzed from the STL struct.

```
iex> Settler.parse(<stl_file_path>) |> Settler.format(:text)

iex> Settler.parse(<stl_file_path>) |> Settler.format(:json)
```

As Settler is not currently available on Hex or Github, it can be included
as a local dependency of another project using the `:path` anotation in your
Mixfile:

```elixir
def deps() do
  [
    {:settler, path: "../settler"}
  ]
end
```
