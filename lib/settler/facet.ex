defmodule Settler.Facet do
  @moduledoc """
  Defines the structure of an individual STL facet,
  including a normal and a calculation for the
  surface area of the triangle identified by the
  three vertices.
  """

  @typedoc """
  Coordinates represent a point or vector in
  three-dimensional space as {x, y, z}
  """
  @type coordinate :: {float, float, float}

  @type t :: %__MODULE__{
          normal: coordinate(),
          vertices: [coordinate()],
          area: float()
        }

  defstruct normal: nil, vertices: [], area: nil
end
