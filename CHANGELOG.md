## v1.0.0

This is a release with major changes in the logic for selecting thumbs and
refactoring to allow easier overriding of parts of the artwork logic in the
application.

Changes include:

- When you're trying to select a retina thumb, the gem will try to select one
  that is at least as wide or wider than the desired size and if there isn't
  such a thumb the search will fallback to normal, non-retina thumbs.
- Requesting a thumb style of '320x' will select sizes like '420x500', i.e.
  sizes with height or a label only if there isn't a single thumb, larger than
  the requested size and with no height and no label.
- `artwork_thumb_for` has been renamed to `attachment_style_for`. Keep in mind
  that now there's a different method named `artwork_thumb_for` which
  selects only a compatible artwork thumb/style. Another new method, named
  `plain_thumb_for` works for non-artwork compatible thumbs, e.g. `:foobar`.
- The internal API has been changed to some extent due to refactoring and
  changes.

## v0.7.3

- Paperclip is no longer a dependency
- Change a little the `auto_height` option of `artwork_tag`

## v0.7.2

- Use `Artwork.current_resolution` instead of `Artwork.actual_resolution` in
  `artwork_thumb_for` when evaluating the alternative sizes. This is to allow
  page and fragment caching where `Artwork.current_resolution` is in the cache
  key.

## v0.7.1

- Hotfix for the new alternative sizes when additional non-numeric option keys
  are being passed to `artwork_thumb_for()` (such as `auto_height: true`).

## v0.7.0

**Backwards-incompatible changes**

- Renamed `Artwork.default_resolution` to `Artwork.base_resolution`
- Renamed `Artwork.actual_resolution_for` to `Artwork.actual_resolution_from`
  and is now private

**Other changes**

- Added support for custom base resolutions via the following syntax:
  `<%= artwork_tag @record, :cover, '800x@1200' %>`
- Added `Artwork.actual_resolution` (set via `Artwork.configure_for(request)`)
- Added support for responsive image sizes via the alternative sizes parameter
  of `Artwork::Model.artwork_thumb_for(name, size, alternative_sizes = nil)`
  Example usage:

    Request full-width images if the current browser's viewport is 480 px or
    less wide:

    ```ruby
    <%= artwork_tag @recrod, :cover, '800x', {480 => '320x@320'} %>
    ```

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
