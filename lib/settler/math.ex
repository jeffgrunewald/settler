defmodule Settler.Math do
  @moduledoc """
  Collection of mathematical functions for calculating
  details of an STL-defined object during/after parsing.
  """

  alias Settler.Facet

  @doc """
  Calculates the surface area of a facet according to
  [Heron's formula](https://en.wikipedia.org/wiki/Heron%27s_formula)
  """
  def facet_area(%Facet{vertices: [x, y, z]}) do
    a = distance_from(x, y)
    b = distance_from(x, z)
    c = distance_from(y, z)
    s = (a + b + c) / 2

    :math.sqrt(abs(s * (s - a) * (s - b) * (s - c)))
  end

  @doc """
  Calculates distance in 3-dimensional Cartesian space
  """
  def distance_from({x1, y1, z1}, {x2, y2, z2}) do
    (:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2) + :math.pow(z2 - z1, 2))
    |> :math.sqrt()
  end

  @doc """
  Compares the vertices of a complete triangle against the
  maximal coordinates at the upper and lower limits of the
  STL-defined object and ensures the highest and lowest
  values are reflected in the output.
  """
  def update_limits(limits, [v1, v2, v3]) do
    limits
    |> update_limit(v1)
    |> update_limit(v2)
    |> update_limit(v3)
  end

  defp update_limit(nil, {x, y, z}), do: {x, x, y, y, z, z}

  defp update_limit({x1, x2, y1, y2, z1, z2}, {x, y, z}) do
    new_x1 = if x > x1, do: x, else: x1
    new_x2 = if x < x2, do: x, else: x2
    new_y1 = if y > y1, do: y, else: y1
    new_y2 = if y < y2, do: y, else: y2
    new_z1 = if z > z1, do: z, else: z1
    new_z2 = if z < z2, do: z, else: z2
    {new_x1, new_x2, new_y1, new_y2, new_z1, new_z2}
  end

  @doc """
  Construct the eight coordinates of a bounding box surrounding
  the STL-defined object based on the maximal values of the
  outer-most vertices.
  """
  def build_bounding_box({x1, x2, y1, y2, z1, z2}) do
    for x <- [x1, x2],
        y <- [y1, y2],
        z <- [z1, z2],
        do: {x, y, z}
  end
end
