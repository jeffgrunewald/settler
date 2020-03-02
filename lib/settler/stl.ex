defmodule Settler.STL do
  @moduledoc """
  Defines the structure of the overall STL data
  structure. Includes an optional name, a list
  of facets as structs, a calculation of the total
  number of triangles (facets) that comprise the
  surface of the object, a calculation of the total
  surface area of the object, and a calculation of
  the minimal bounding box required to fully surround
  the complete shape with minimal required volume.
  """

  @typedoc """
  Bounding box contains a list of eight coordinates
  representing the corners of the 3D square or rectangle
  required to surround an object.
  """
  @type bounding_box :: [Settler.Facet.coordinate()]

  @type t :: %__MODULE__{
          name: String.t(),
          facets: [Settler.Facet.t()],
          triangles: integer(),
          bounding_box: bounding_box(),
          area: float()
        }

  defstruct name: nil,
            facets: [],
            triangles: 0,
            bounding_box: [],
            area: 0
end
