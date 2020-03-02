defmodule SettlerTest do
  use ExUnit.Case

  alias Settler.{Facet, STL}

  @simple ~s(solid simple
               facet normal 0 0 0
                   outer loop
                       vertex 0 0 0
                       vertex 1 0 0
                       vertex 1 1 1
                   endloop
               endfacet
               facet normal 0 0 0
                   outer loop
                       vertex 0 0 0
                       vertex 0 1 1
                       vertex 1 1 1
                   endloop
               endfacet
             endsolid simple)

  @simple_file "test/support/simple.stl"
  @moon_file "test/support/Moon.stl"

  describe "Parser" do
    test "parses simple stl" do
      assert %STL{
              area: 1.4142135623730956,
              bounding_box: [
                {1.0, 1.0, 1.0},
                {1.0, 1.0, 0.0},
                {1.0, 0.0, 1.0},
                {1.0, 0.0, 0.0},
                {0.0, 1.0, 1.0},
                {0.0, 1.0, 0.0},
                {0.0, 0.0, 1.0},
                {0.0, 0.0, 0.0}
              ],
              facets: [
                %Facet{
                  area: 0.7071067811865478,
                  normal: {0.0, 0.0, 0.0},
                  vertices: [{0.0, 0.0, 0.0}, {0.0, 1.0, 1.0}, {1.0, 1.0, 1.0}]
                },
                %Facet{
                  area: 0.7071067811865478,
                  normal: {0.0, 0.0, 0.0},
                  vertices: [{0.0, 0.0, 0.0}, {1.0, 0.0, 0.0}, {1.0, 1.0, 1.0}]
                }
              ],
              name: "simple",
              triangles: 2
            } == Settler.parse(@simple)
    end

    test "parses simple stl from file" do
      simple_stl = Settler.parse_file(@simple_file)
      assert simple_stl.area == 1.4142135623730956

      assert simple_stl.bounding_box == [
              {1.0, 1.0, 1.0},
              {1.0, 1.0, 0.0},
              {1.0, 0.0, 1.0},
              {1.0, 0.0, 0.0},
              {0.0, 1.0, 1.0},
              {0.0, 1.0, 0.0},
              {0.0, 0.0, 1.0},
              {0.0, 0.0, 0.0}
            ]

      assert simple_stl.triangles == 2
    end

    test "parses complex stl from file" do
      moon_stl = Settler.parse_file(@moon_file)

      facet = %Facet{
        area: 0.030957250851269637,
        normal: {0.363046, 0.316228, 0.876469},
        vertices: [{0.878412, 0.2, 2.79904}, {0.853196, 0.35, 2.75536}, {0.516641, 0.2, 2.94889}]
      }

      assert moon_stl.triangles == 116
      assert moon_stl.area == 7.772634278919953

      assert moon_stl.bounding_box == [
              {1.62841, 0.35, 3.0},
              {1.62841, 0.35, 0.0},
              {1.62841, 0.0, 3.0},
              {1.62841, 0.0, 0.0},
              {0.0, 0.35, 3.0},
              {0.0, 0.35, 0.0},
              {0.0, 0.0, 3.0},
              {0.0, 0.0, 0.0}
            ]

      assert facet in moon_stl.facets
    end
  end

  describe "Formatter" do
    setup do
      stl = @simple_file |> Settler.parse_file

      [stl: stl]
    end

    test "returns a formatted text block", %{stl: stl} do
      assert Settler.format(stl, :text) == ~s|Name: simple\nNumber of Triangles: 2\nSurface Area: 1.4142135623730956\nBounding Box:\n      {x: 1.0, y: 1.0, z: 1.0},\n      {x: 1.0, y: 1.0, z: 0.0},\n      {x: 1.0, y: 0.0, z: 1.0},\n      {x: 1.0, y: 0.0, z: 0.0},\n      {x: 0.0, y: 1.0, z: 1.0},\n      {x: 0.0, y: 1.0, z: 0.0},\n      {x: 0.0, y: 0.0, z: 1.0},\n      {x: 0.0, y: 0.0, z: 0.0}|
    end

    test "returns a json object", %{stl: stl} do
      assert Settler.format(stl, :json) == ~s|{"name":"simple","number_of_triangles":2,"surface_area":1.4142135623730956,"bounding_box":[{"x":1.0,"y":1.0,"z":1.0},{"x":1.0,"y":1.0,"z":0.0},{"x":1.0,"y":0.0,"z":1.0},{"x":1.0,"y":0.0,"z":0.0},{"x":0.0,"y":1.0,"z":1.0},{"x":0.0,"y":1.0,"z":0.0},{"x":0.0,"y":0.0,"z":1.0},{"x":0.0,"y":0.0,"z":0.0}]}|
    end

    test "returns output with name undefined if solid name not specified", %{stl: stl} do
      unnamed_stl = %{stl | name: nil}

      assert Settler.format(unnamed_stl, :json) == ~s|{"name":"undefined","number_of_triangles":2,"surface_area":1.4142135623730956,"bounding_box":[{"x":1.0,"y":1.0,"z":1.0},{"x":1.0,"y":1.0,"z":0.0},{"x":1.0,"y":0.0,"z":1.0},{"x":1.0,"y":0.0,"z":0.0},{"x":0.0,"y":1.0,"z":1.0},{"x":0.0,"y":1.0,"z":0.0},{"x":0.0,"y":0.0,"z":1.0},{"x":0.0,"y":0.0,"z":0.0}]}|
    end
  end
end
