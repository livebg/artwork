require 'spec_helper'

describe 'Model without paperclip' do
  class UserWithoutPaperclip
    include Artwork::Model

    def attachment_styles_for(attachment_name)
      if attachment_name.to_sym == :avatar
        ModelSpec::IMAGE_STYLES.keys
      end
    end

    def avatar
      Avatar.new
    end
  end

  class Avatar
    def url(style, options)
      "/avatar-#{style}.jpg"
    end
  end

  it_behaves_like 'an artwork model' do
    let(:model) { UserWithoutPaperclip }
    let(:instance) { UserWithoutPaperclip.new }
    let(:attachment_name) { :avatar }
  end

  # if you want to use artwork_tag like this:
  # <%= artwork_tag record, :avatar, '320x', auto_height: true %>
  # you will have to provide Avatar#width and Avatar#height which will be used to generate
  # the padding-bottom % of the .img-holder
  #
  # n.b. you could use the artwork_tag also like this:
  # <%= artwork_tag record, :avatar, '320x', auto_height: [image_width, image_height] %>
end
