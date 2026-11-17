# Depth clock: design rules

How the clock in `index.html` should sit on each wallpaper. The `widgets.json` and `mask.png` in each wallpaper's folder follow these rules.

## Type

- **Time:** New York, weight 860, with optical size fixed at 36 (`"opsz" 36`). The automatic display cut has hairlines that the painting's texture and the masks shred. Tracking is -0.035em, with tabular figures so each digit slot stays in a fixed place.
- **Date:** New York italic, weight 600, at about 1/6 of the time's size. It always goes in its own open space, either directly above or directly below the time.
- **Halo:** a two-layer shadow in the opposite tone to the text (`shadow-color`, strength set by `halo`), never a scrim behind the text. Because the mask sits above the halo, the halo also disappears under occluders, which strengthens the depth.

## Colour

- **Tone:** light text on darker regions, dark text on lighter ones. Aim for at least 4.5:1 against the region and at least 3:1 at the worst patch.
- **Separation:** the digits must contrast with whatever covers them, with at least about 30 L* of difference. If the digits and the occluder share a tone, the overlap reads as missing ink rather than depth.
- **Hue:** take it from the scene, using the brightest highlight for light text and the deepest shadow for dark text. Keep it desaturated, never pure white or black.

## Placement and occlusion

- **Where:** the clock goes in calm negative space, usually the top 40% of the screen, at 15–20cqh.
- **Occluders:** something unambiguously in front in the painting, such as a character, an awning, a balcony or a near plant. Thin scatter doesn't count.
- **Occlusion budget,** as a share of each digit's area at worst-case times:

  - **First hour digit (0–2 only):** at most 30%, outer-left edge or bottom band
  - **Second hour digit, first minute digit:** at most 10%, bottom band
  - **Last minute digit:** at most 15%, outer-right quarter or bottom 20%
  - **Colon:** any amount, anywhere
  - **Date:** never covered

- **Never cover:** a digit's waist or middle, a digit's top-left corner, or a vertical band through the middle half of a digit.
- **No contradictions:** never draw the clock over a foreground object that isn't in the mask. It would read as being in front of it.

## Masks

- **Characters or objects against sky:** use Vision subject lifting, cropped to the region around the clock.
- **Saturated objects or skylines:** use a hue or brightness threshold, then a morphological close and hole fill.
- **Straight-edged architecture or foliage next to the clock:** hand-trace or threshold within a rectangle around the clock, then delete every fragment outside it.
- **Edges:** grow the mask about 1px, then feather. Use about 1px for inked edges and 2–3px for painterly ones.
- **Format:** shape only (black plus alpha), at the same aspect ratio as `background.jpg`.

## Check

Simulate placements at "18:58" and "23:59" and check per-digit occlusion against the budget before making them live. `wallpaper.sh keep` reloads the current wallpaper's settings and mask. Edits to `style.css` or `index.html` need Plash to be restarted.
