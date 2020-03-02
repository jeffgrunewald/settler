defmodule Settler do
  @moduledoc """
  Defines the API functions for loading and
  parsing STL ASCII files as a file path or newline-
  delimited string and returns an STL struct
  listing the name and list of vertices outlined
  by the document, as well as the calculated surface
  area, number of triangles, and bounding box for
  the overall shape.
  """
  alias Settler.{Facet, Math, Parser, STL}

  @doc """
  Takes a file path to a correctly formatted STL ASCII
  file, parses the document and returns an STL struct
  with the name, list of vertices, and calculated
  surface area, number of triangles, and bounding box of
  the shape.
  """
  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> build_stl()
  end

  @doc """
  Takes a newline-delimited string defining a
  3-dimensional object in the STL ASCII standard
  and returns an STL struct with the name, list of vertices,
  and calculated surface area, number of triangles, and bounding
  box of the shape.
  """
  def parse(stl) do
    stl
    |> String.split("\n")
    |> build_stl()
  end

  @doc """
  Takes an STL struct and a format atom and returns a
  string representation of the STL object's details in
  the desired format (all data except the list of vertices).

  Sets the object name to the string "undefined" if one is not
  specified.
  """
  def format(stl, format \\ :text) do
    name = stl.name || "undefined"
    format_output(stl, name, format)
  end

  defp format_output(stl, name, :text) do
    ~s|Name: #{name}\nNumber of Triangles: #{stl.triangles}\nSurface Area: #{stl.area}\nBounding Box:#{
      format_bbox_text(stl.bounding_box)
    }|
  end

  defp format_output(stl, name, :json) do
    ~s|{\"name\":\"#{name}\",\"number_of_triangles\":#{stl.triangles},\"surface_area\":#{stl.area},\"bounding_box\":[#{
      format_bbox_json(stl.bounding_box)
    }]}|
  end

  defp build_stl(stream) do
    Enum.reduce_while(
      stream,
      {%STL{}, %Facet{}, nil},
      &parse_lines/2
    )
    |> add_bounding_box()
  end

  defp parse_lines(line, {stl, facet, limits}) do
    line
    |> Parser.stl()
    |> elem(1)
    |> handle_line({stl, facet, limits})
  end

  defp handle_line([name: [name]], {stl, facet, limits}) do
    {:cont, {%{stl | name: name}, facet, limits}}
  end

  defp handle_line([normal: coord], {stl, facet, limits}) do
    {:cont, {stl, %{facet | normal: parse_coordinate(coord)}, limits}}
  end

  defp handle_line([vertex: coord], {stl, facet, limits}) do
    update_vertices(stl, facet, limits, parse_coordinate(coord))
  end

  defp handle_line([:eof | _], {stl, facet, limits}) do
    {:halt, {stl, facet, limits}}
  end

  defp handle_line(_, {stl, facet, limits}) do
    {:cont, {stl, facet, limits}}
  end

  defp update_vertices(stl, %Facet{vertices: v, normal: n} = facet, limits, vertex)
       when length(v) == 2 and n != nil do
    new_facet = %{facet | vertices: v ++ [vertex]}
    area = Math.facet_area(new_facet)

    {:cont,
     {%{
        stl
        | facets: [%{new_facet | area: area} | stl.facets],
          area: stl.area + area,
          triangles: stl.triangles + 1
      }, %Facet{}, Math.update_limits(limits, new_facet.vertices)}}
  end

  defp update_vertices(stl, facet, limits, vertex) do
    {:cont, {stl, %{facet | vertices: facet.vertices ++ [vertex]}, limits}}
  end

  defp add_bounding_box({%STL{} = stl, _, limits}) do
    %{stl | bounding_box: Math.build_bounding_box(limits)}
  end

  defp parse_coordinate([x, y, z]) do
    {Float.parse(x) |> elem(0), Float.parse(y) |> elem(0), Float.parse(z) |> elem(0)}
  end

  defp format_bbox_text(bbox) do
    for {x, y, z} <- bbox do
      "\n      {x: #{x}, y: #{y}, z: #{z}}"
    end
    |> Enum.join(",")
  end

  defp format_bbox_json(bbox) do
    for {x, y, z} <- bbox do
      "{\"x\":#{x},\"y\":#{y},\"z\":#{z}}"
    end
    |> Enum.join(",")
  end
end
