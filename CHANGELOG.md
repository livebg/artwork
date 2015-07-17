## v0.7.0

**Backwards-incompatible changes**

- Renamed `Artwork.default_resolution` to `Artwork.base_resolution`
- Renamed `Artwork.actual_resolution_for` to `Artwork.actual_resolution_from`
  and is now private

**Other changes**

- Added support for custom base resolutions via the following syntax:
  `<%= artwork_tag @record, :cover, '800x@1200' %>`

## v0.6.1

- Added `Artwork.actual_resolution_for(request)` which returns the current
  client's browser width, in pixels.

## v0.6.0

- Don't change viewport width & retina cookies when loaded in an iframe.

## v0.5.0

No changes.

## v0.4.2

- Set the cookies with `path=/`.

## v0.4.1

- Compatibility with newer versions of the Paperclip gem.