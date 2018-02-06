defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello
      :world

  """

  # Structs have 2 advantages over maps:
  # A struct is a map under the hood.
  # If you know the properties use a struct.
  # (A) they can be assigned default values
  # (B) additional compile time checking properties
  # (C) cannot add additional properties

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input) # second argument
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index }) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = { horizontal, vertical}
      bottom_right = { horizontal + 50, vertical + 50 }

      {top_left, bottom_right}
    end

    %Identicon.Image{ image | pixel_map: pixel_map }
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  # Elixir, if you refer to a function it is going to invoke it.
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1) # pass a referece (a function)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [ first, second | _tail ] = row
    row ++ [second, first]
  end

  # Create a new record and paste properties into here
  # Pattern matching arguments
  def pick_color(%Identicon.Image{ hex: [r, g, b | _tail] } = image) do
    %Identicon.Image{image | color: { r, g, b}}
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
