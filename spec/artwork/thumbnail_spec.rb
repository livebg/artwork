require 'spec_helper'

module Artwork
  describe Thumbnail do
    expected_defaults = {:compatible? => true}

    examples = {
      :'320x'               => {:width => 320,  :height => nil, :retina? => false, :label => nil},
      :'320x_2x'            => {:width => 320,  :height => nil, :retina? => true,  :label => nil},
      :'640x_2x'            => {:width => 640,  :height => nil, :retina? => true,  :label => nil},
      :'640x'               => {:width => 640,  :height => nil, :retina? => false, :label => nil},
      :'1280x'              => {:width => 1280, :height => nil, :retina? => false, :label => nil},
      :'1280x_2x'           => {:width => 1280, :height => nil, :retina? => true,  :label => nil},
      :'2000x'              => {:width => 2000, :height => nil, :retina? => false, :label => nil},
      :'1500x_2x'           => {:width => 1500, :height => nil, :retina? => true,  :label => nil},
      :'320x_some_label'    => {:width => 320,  :height => nil, :retina? => false, :label => 'some_label'},
      :'320x_some_label_2x' => {:width => 320,  :height => nil, :retina? => true,  :label => 'some_label'},
      :'320x500'            => {:width => 320,  :height => 500, :retina? => false, :label => nil},
      :'320x500_2x'         => {:width => 320,  :height => 500, :retina? => true,  :label => nil},
      :'320x500_crop'       => {:width => 320,  :height => 500, :retina? => false, :label => 'crop'},
      :'320x500_crop_2x'    => {:width => 320,  :height => 500, :retina? => true,  :label => 'crop'},
      :'320x_'              => {:width => 320,  :height => nil, :retina? => false, :label => ''},
      :'320x500_'           => {:width => 320,  :height => 500, :retina? => false, :label => ''},
      :'320x500__2x'        => {:width => 320,  :height => 500, :retina? => true,  :label => ''},
      :unsupported          => {:compatible? => false},
      'unsupported_thumb'   => {:compatible? => false},
    }

    examples.each do |thumb_name, expected_properties|
      expected_properties = expected_defaults.merge(expected_properties)
      expected_properties.each do |field_name, expected_value|
        it "##{field_name} is #{expected_value.inspect} for #{thumb_name}" do
          thumbnail = Thumbnail.new(thumb_name)
          expect(thumbnail.send(field_name)).to eq expected_value
        end
      end

      compatible = expected_properties[:compatible?]
      it "compatible? is true for #{thumb_name.inspect}" do
        expect(Thumbnail.compatible?(thumb_name)).to eq compatible
      end
    end

    describe '#eq' do
      it 'is true for different objects with the same width, height, label and retina flag' do
        expect(Thumbnail.new(:'1200x500_crop_2x')).to eq Thumbnail.new('1200x500_crop_2x')
        expect(Thumbnail.new(:'1200x_2x')).to eq Thumbnail.new('1200x_2x')
        expect(Thumbnail.new(:'1200x')).to eq Thumbnail.new('1200x')
        expect(Thumbnail.new(:'1200x_black_and_white')).to eq Thumbnail.new('1200x_black_and_white')
      end

      it 'is false for different objects if any of the width, height, label or retina flag differ' do
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1200x500_crop')
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1200x500crop_2x')
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1201x500_crop_2x')
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1500x')
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1200x400_crop_2x')
      end
    end

    describe '#aspect_ratio' do
      it 'is nil if height is not present or is zero' do
        expect(Thumbnail.new('400x_label_2x').aspect_ratio).to be_nil
        expect(Thumbnail.new('400x_2x').aspect_ratio).to be_nil
        expect(Thumbnail.new('400x_').aspect_ratio).to be_nil
        expect(Thumbnail.new('400x').aspect_ratio).to be_nil
        expect(Thumbnail.new('400x0').aspect_ratio).to be_nil
      end

      it 'is calculated as a decimal when both a width and a height are present' do
        expect(Thumbnail.new('400x300').aspect_ratio).to be_within(0.1).of(1.33)
        expect(Thumbnail.new('1600x900').aspect_ratio).to be_within(0.1).of(1.78)
        expect(Thumbnail.new('1600x900_with_label').aspect_ratio).to be_within(0.1).of(1.78)
        expect(Thumbnail.new('1600x900_with_label_2x').aspect_ratio).to be_within(0.1).of(1.78)
      end
    end

    describe '#same_aspect_ratio_with?' do
      it 'returns nil if either thumbs have no clear height' do
        expect(Thumbnail.new('400x300').same_aspect_ratio_with?(Thumbnail.new('400x'))).to be_nil
        expect(Thumbnail.new('400x0').same_aspect_ratio_with?(Thumbnail.new('400x300'))).to be_nil
      end

      it 'returns true if thumbs have aspect ratios within 0.1 of one another' do
        expect(Thumbnail.new('400x300').same_aspect_ratio_with?(Thumbnail.new('400x300'))).to be true
        expect(Thumbnail.new('400x300').same_aspect_ratio_with?(Thumbnail.new('1600x1200_with_label_2x'))).to be true
        expect(Thumbnail.new('400x300').same_aspect_ratio_with?(Thumbnail.new('400x301'))).to be true
      end

      it 'returns false if thumbs have different aspect ratios not within 0.1 of one another' do
        expect(Thumbnail.new('400x300').same_aspect_ratio_with?(Thumbnail.new('400x200'))).to be false
        expect(Thumbnail.new('400x300').same_aspect_ratio_with?(Thumbnail.new('5x10'))).to be false
      end
    end

    describe 'comparison' do
      it 'is based on the thumb width' do
        small  = Thumbnail.new('90x_crop')
        medium = Thumbnail.new('500x_crop')
        large  = Thumbnail.new('1090x_2x')
        huge   = Thumbnail.new('3200x')

        unsorted = [huge, large, small, medium]

        expect(unsorted.sort).to eq [small, medium, large, huge]
      end
    end
  end
end
