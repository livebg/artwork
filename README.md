# Artwork

Automated user-resolution-based image size choosing for your Rails views, but
done at the backend. Works for any browser. Delivers the information needed for
the calculations (browser window's dimentions and device's pixel ratio) via a
cookie. Supports only Paperclip attachments.

The gem should be thread-safe and should work with Rails 2.3 or newer.

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
- Paperclip 2.3 or newer
- A JavaScript runtime

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

Add the following line at the top of your `<head>` section:

    <%= activate_resolution_independence %>

## Configuration

Set the following variables in an app initializer:

- `Artwork.supported_resolutions_list`
- `Artwork.default_resolution`

Name your Paperclip attachment styles using the following convention:

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

## Usage Example

Configure the gem by putting the following code in `config/initializers/artwork.rb`:

    Artwork.default_resolution = 1440
    Artwork.supported_resolutions_list = [1024, 1280, 1440, 1600, 1920, 2048, 3200, 3840]

Include `Artwork::Model` in your models which have artworks.

Include `Artwork::Controller` in your `ApplicationController` or wherever you
want to have the artwork functionality.

Then you can use `Artwork.load_2x_images?`, `Artwork.current_resolution` and
the `artwork_tag` view helper. Example:

    <%= artwork_tag @film, :board, :'1440x', :image => {:class => 'poster'} %>
    <%= artwork_tag @gallery, :cover, :'900x' %>

## Contributing

1. [Fork it](https://github.com/mitio/artwork/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes
4. Make sure the tests pass (`bundle exec rake`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request
