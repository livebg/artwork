require 'spec_helper'

module Artwork
  describe Thumbnail do
    expected_defaults = {:compatible? => true}

    examples = {
      :'320x'               => {:width => 320,  :retina? => false, :label => ''},
      :'320x_2x'            => {:width => 320,  :retina? => true,  :label => ''},
      :'640x_2x'            => {:width => 640,  :retina? => true,  :label => ''},
      :'640x'               => {:width => 640,  :retina? => false, :label => ''},
      :'1280x'              => {:width => 1280, :retina? => false, :label => ''},
      :'1280x_2x'           => {:width => 1280, :retina? => true,  :label => ''},
      :'2000x'              => {:width => 2000, :retina? => false, :label => ''},
      :'1500x_2x'           => {:width => 1500, :retina? => true,  :label => ''},
      :'320x_some_label'    => {:width => 320,  :retina? => false, :label => 'some_label'},
      :'320x_some_label_2x' => {:width => 320,  :retina? => true,  :label => 'some_label'},
      :'320x500'            => {:width => 320,  :retina? => false, :label => '500'},
      :'320x500_2x'         => {:width => 320,  :retina? => true,  :label => '500'},
      :'320x500_crop'       => {:width => 320,  :retina? => false, :label => '500_crop'},
      :'320x500_crop_2x'    => {:width => 320,  :retina? => true,  :label => '500_crop'},
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
      it 'is true for different objects with the same width, label and retina flag' do
        expect(Thumbnail.new(:'1200x500_crop_2x')).to eq Thumbnail.new('1200x500_crop_2x')
        expect(Thumbnail.new(:'1200x_2x')).to eq Thumbnail.new('1200x_2x')
        expect(Thumbnail.new(:'1200x')).to eq Thumbnail.new('1200x')
        expect(Thumbnail.new(:'1200x_black_and_white')).to eq Thumbnail.new('1200x_black_and_white')
      end

      it 'is false for different objects if any of the width, label or retina flag differ' do
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1200x500_crop')
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1200x500crop_2x')
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1201x500_crop_2x')
        expect(Thumbnail.new(:'1200x500_crop_2x')).not_to eq Thumbnail.new('1500x')
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
