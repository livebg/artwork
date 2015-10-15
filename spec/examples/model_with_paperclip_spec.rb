require 'spec_helper'
require 'active_record'
require 'paperclip'

ActiveRecord::Base.raise_in_transactional_callbacks = true

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :user_with_paperclips, :force => true do |t|
    t.string :avatar_file_name
    t.string :avatar_content_type
    t.integer :avatar_file_size
    t.datetime :avatar_updated_at
  end
end

describe 'Model with paperclip', :type => :model do
  class UserWithPaperclip < ActiveRecord::Base
    include Paperclip::Glue
    include Artwork::Model

    has_attached_file :avatar,
      :path => ':basename-:style.:extension',
      :url => '/:basename-:style.:extension',
      :styles => ModelSpec::IMAGE_STYLES
  end

  it_behaves_like 'an artwork model' do
    let(:model) { UserWithPaperclip }
    let(:instance) do
      UserWithPaperclip.find_or_create_by(
        avatar_file_name: 'avatar.jpg',
        avatar_content_type: 'image/jpeg',
        avatar_file_size: 3000,
        avatar_updated_at: 1.day.ago
      )
    end
    let(:attachment_name) { :avatar }
  end
end
