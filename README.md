# Artwork

Automated image size scaling view helpers for your frontend, but done in the
backend. Works for any browser. Delivers the information needed for the
calculations (browser window's dimentions and device's pixel ratio) via a
cookie. Supports only Paperclip attachments.

Example usage:

    <%= artwork_tag person, :avatar, '100x' %>

## Installation

Add this line to your application's Gemfile:

    gem 'artwork'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artwork

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
