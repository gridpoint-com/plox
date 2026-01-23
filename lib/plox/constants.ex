defmodule Plox.Constants do
  @moduledoc """
  Constants used throughout Plox components.
  """

  @doc """
  SVG presentation attributes that can be passed via @rest in components.

  See: https://svgwg.org/svg2-draft/styling.html#TermPresentationAttribute
  """
  def svg_presentation_attrs do
    ~w(
      alignment-baseline
      baseline-shift
      clip-path
      clip-rule
      color
      color-interpolation
      color-interpolation-filters
      cursor
      direction
      display
      dominant-baseline
      fill
      fill-opacity
      fill-rule
      filter
      flood-color
      flood-opacity
      font-family
      font-size
      font-size-adjust
      font-stretch
      font-style
      font-variant
      font-weight
      glyph-orientation-horizontal
      glyph-orientation-vertical
      image-rendering
      letter-spacing
      lighting-color
      marker-end
      marker-mid
      marker-start
      mask
      mask-type
      opacity
      overflow
      paint-order
      pointer-events
      shape-rendering
      stop-color
      stop-opacity
      stroke
      stroke-dasharray
      stroke-dashoffset
      stroke-linecap
      stroke-linejoin
      stroke-miterlimit
      stroke-opacity
      stroke-width
      text-anchor
      text-decoration
      text-overflow
      text-rendering
      transform
      transform-origin
      unicode-bidi
      vector-effect
      visibility
      white-space
      word-spacing
      writing-mode
    )
  end

  @doc """
  Default gap between graph boundary and labels (in pixels).
  """
  def default_label_gap, do: 16
end
