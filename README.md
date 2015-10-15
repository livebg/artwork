# Artwork

The Artwork gem provides simple server-side responsive images support for Rails
which is similar in concept to the `<picture>` tag spec but requires no
JavaScript, doesn't make extra requests and works in all browsers.

You could use it either with Paperclip attachments or implement a couple of methods yourself in plain Ruby.

The gem should be thread-safe and should work with Rails 2.3 or newer.

## How it works

To do this "magic", the gem needs some information from the browser. Two pieces
of knowledge travel from the browser to the server via a cookie:

- the browser window's dimentions (width in pixels)
- the device's pixel ratio

These values are set in a cookie as early as possible during the first page
load and then the page is reloaded with JavaScript. If these values change
later on, for example if the user resizes their browser, no automatic reloading
is performed.

## An example

Say you've declared a default (base) resolution of 1440px. You design based on
that resolution. You want to show the user an image which is half of the width
of the user's browser. You then add the following to your view:

    <%= artwork_tag @post, :cover_image, '720x' %>

Say you have the following image thumbs prepared (defined with imagemagick
geometry strings):

    256x>
    512x>
    1024x>
    2048x>

Let's also assume a user with a full HD screen opens your page (1920x1080).
Then, `artwork_tag` will look for a 960px wide image (which is 50% of 1920px).
You don't have that exact size on the server, so the helper will choose the
1024px-wide version of the image.

If the user's screen is retina (ie. with a device-to-pixel ratio > 1.0) and if
you have a _2x versions of your thumbs, the helper will choose the _2x one.

## Requirements

- Ruby 1.8.7 or newer
- Rails 2.3 or newer
- A JavaScript runtime

If you're using Paperclip, it should be 2.3 or newer.

## Installation

Add these lines to your application's Gemfile:

    gem 'artwork'
    gem 'therubyracer'

You can skip `therubyracer` if you have other JavaScript environments available
on your machine (including on the prodiction one).

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artwork

Add the following line at the top of your `<head>` section, as early as
possible, but **after** any `<meta viewport>` tags:

    <%= activate_resolution_independence %>

This will add a script which will set the cookie with the dimentions and
reload the current page. If the dimentions need updating, it will do the same thing.

This reloading causes some browsers to display unstyled html,
so you could prevent this if you add (*ABOVE* the top script):

    <style> .artwork-reload-splash body { display: none; } </style>
    <%= activate_resolution_independence %>

### When you have a viewport meta tag

If you have `<meta viewport>` tags, place them **before** the
`activate_resolution_independence` call.

### Usage in frames

The client-side code which checks for the current browser's resolutions will be
disabled by default when the site is not the topmost frame, ie. when loaded from
an iframe.

You can override this behaviour by setting a truthy value to a global variable:

    window.useArtworkInFrames = true

This has to happen before the `<%= activate_resolution_independence %>` call.

## Configuration

Set the following variables in an app initializer:

- `Artwork.supported_resolutions_list`
- `Artwork.base_resolution`

Name your attachment styles using the following convention:

    :'320x'
    :'320x_2x'
    :'320x_some_label'
    :'320x_some_label_2x'
    :'320x500'
    :'320x500_2x'
    :'320x500_crop'
    :'320x500_crop_2x'
    :'320x500_black_and_white_crop'
    :'320x500_black_and_white_crop_2x'

The artwork methods will recognize and work with these styles. All other naming
conventions will be ignored and will bypass the artwork auto-sizing logic.

### Plain Ruby Model

A plain Ruby model will look like this:
[example in the specs](spec/examples/model_without_paperclip_spec.rb)

```ruby
class User
  include Artwork::Model

  def attachment_styles_for(attachment_name)
    if attachment_name.to_sym == :avatar
      [
        :'320x',
        :'320x_2x',
        :'320x_some_label',
        :'320x_some_label_2x',
        :'320x500',
        :'320x500_2x',
        :'320x500_crop',
        :'320x500_crop_2x',
        :'320x500_black_and_white_crop',
        :'320x500_black_and_white_crop_2x',
      ]
    end
  end

  def avatar
    Avatar.new
  end
end

class Avatar
  def url(style, options)
    "/avatars/avatar-#{style}.jpg"
  end
end
```

### ActiveRecord Model with Paperclip

An ActiveRecord Model with Paperclip will look like this:
[example in the specs](spec/examples/model_with_paperclip_spec.rb)

```ruby
class UserWithPaperclip < ActiveRecord::Base
  include Artwork::Model

  has_attached_file :avatar,
    path: '/tmp/avatars/:basename-:style.:extension',
    url: '/avatars/:basename-:style.:extension',
    styles: {
      :'320x'               => '320x>',
      :'320x_2x'            => '640x>',
      :'320x_some_label'    => '320x>',
      :'320x_some_label_2x' => '640x>',
      :'320x500'            => '320x500>',
      :'320x500_2x'         => '640x1000>',
      :'320x500_crop'       => '320x500#',
      :'320x500_crop_2x'    => '640x1000#',
    }
end
```

## Usage Example

Configure the gem by putting the following code in `config/initializers/artwork.rb`:

    Artwork.base_resolution = 1440
    Artwork.supported_resolutions_list = [1024, 1280, 1440, 1600, 1920, 2048, 3200, 3840]

Include `Artwork::Model` in your models which have artworks.

Include `Artwork::Controller` in your `ApplicationController` or wherever you
want to have the artwork functionality.

Then you can use `Artwork.load_2x_images?`, `Artwork.current_resolution` and
the `artwork_tag` view helper. Example:

    <%= artwork_tag @film, :board, :'1440x', :image => {:class => 'poster'} %>
    <%= artwork_tag @gallery, :cover, :'900x' %>

### Base (default) resolution

The base resolution defeined by `Artwork.base_resolution` is there to assist
in development and to make calculating the image width percentage in relation
to the viewport width easier.

For example, to define a half-width image in a setting where your base
resolution is 1600 px, you can use:

    <%= artwork_tag @record, :cover, :'800x' %>

In general, it's convenient to set the base resolution to what your dev team's
screen width is.

### Custom base resolutions

The gem supports per-tag base resolutions via the following syntax:

    <%= artwork_tag @record, :cover, :'800x@1200' %>

This effectively means "size the image as 2/3 of the viewport width".

### Different image sizes based on different browser widths

There is basic media query-like support built into
`Artwork::Model.artwork_thumb_for(name, size, alternative_sizes = nil)`.

For example, to request a full width image if the current browser's viewport
is 480px or less wide, you can use the following code:

```ruby
<%= artwork_tag @recrod, :cover, '800x', {480 => '320x@320'} %>
```

## Thumb Selection Algorithm

The following criteria are taken into account for picking up the appropriate
thumb name:

- The `base_resolution` specified in the Artwork configuration file.
- The current resolition, approximated to the nearest supported resolution
  which is larger than the current user's one.
- Whether or not the screen is retina.
- The width of the requested thumb size (e.g. `400` for `400x300_crop`).
- The label of the requested thumb (e.g. `crop` for `400x300_crop`); the label
  will be ignored, if it is not specified, e.g. for `400x300` or `400x`. The
  label will be locked to a blank one if the request is for a thumb like this:
  `400x300_`.
- The aspect ratio of the requested thumb (e.g. `4/3` for `400x300_crop`); the
  aspect ratio will be ignored if there is no height specified in the requested
  thumb, e.g. for a request like `400x_crop`.

For a thumb to be returned as matching, all of the following must be true:

- It must be the smallest thumb which is still larger than the requested width,
  scaled for the current resolution.
- If the requested thumb has a label (including a blank one, like in `400x_`),
  the thumb must match the requested label.
- If the requested thumb specifies an aspect ratio, the matching thumb must
  have the same aspect ratio, within a delta of 0.1. If no aspect ratio is
  specified in the request, aspect ratio checks will not be performed.
- If the current device is a retina device, a retina thumb will be preferred.
  If no retuna thumb exists, a non-retina one will be selected.

If no such thumb exist, the largest one will match.

## Contributing

1. [Fork it](https://github.com/mitio/artwork/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes
4. Make sure the tests pass (`bundle exec rake`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request
