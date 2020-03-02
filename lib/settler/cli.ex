defmodule Settler.CLI do
  @moduledoc """
  Defines the command line interface to the
  Settler STL parser.
  """

  def main(args) do
    args
    |> parse_args()
    |> process_options()
  end

  defp parse_args(args) do
    OptionParser.parse(args, [switches: [format: :string], aliases: [o: :format]])
  end

  defp process_options(options) do
    case options do
      {text, [path], _} when text in [[], [format: "text"]] ->
        path
        |> Settler.parse_file()
        |> Settler.format(:text)
        |> IO.puts()

      {[format: "json"], [path], _} ->
        path
        |> Settler.parse_file()
        |> Settler.format(:json)
        |> IO.puts()

      _ ->
        do_help()
    end
  end

  defp do_help() do
    IO.puts(
      ~s(
        Usage:
        settler [path]

        Example:
        ./settler foo/bar.stl
      )
    )

    System.halt(0)
  end
end
