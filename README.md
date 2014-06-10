# Artwork

Automated user-resolution-based image size choosing for your Rails views, but
done at the backend. Works for any browser. Delivers the information needed for
the calculations (browser window's dimentions and device's pixel ratio) via a
cookie. Supports only Paperclip attachments.

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

## Installation

Add this line to your application's Gemfile:

    gem 'artwork'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artwork

Add the following in your `application.js` manifest:

    //= require artwork

If you're using an older version of Rails which does not support the asset
pipeline, run the following command from within the app to copy the necessary
asset files in your `public/` folder first:

    ./script/generate artwork_assets

And then manually include them with `javascript_include_tag` in your layout(s).

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

Include `Artwork::Model` in your `ApplicationController` or wherever you want
to have the artwork functionality.

Then you can use `Artwork.load_2x_images?`, `Artwork.current_resolution` and
the `artwork_tag` view helper. Example:

    <%= artwork_tag @film, :board, :'1440x', :image => {:class => 'poster'} %>
    <%= artwork_tag @gallery, :cover, :'900x' %>

## Contributing

1. Fork it ( https://github.com/[my-github-username]/artwork/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
