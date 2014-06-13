require 'spec_helper'

module Artwork
  describe View do
    let(:view_context) { Class.new { include View }.new }

    describe '#activate_resolution_independence' do
      it 'returns an HTML script tag' do
        stub_const('Uglifier', double(:compile => 'compiled_script'))
        expect(Thread).to receive(:current).and_return({})
        expect(view_context).to receive(:content_tag).with(:script, 'compiled_script').and_return('compiled_script_html')

        expect(view_context.activate_resolution_independence).to eq 'compiled_script_html'
      end

      it 'caches the compiled script in Thread.current' do
        expect(Thread).to receive(:current).and_return(:artwork_script => 'cached_compiled_script')
        expect(view_context.activate_resolution_independence).to eq 'cached_compiled_script'
      end
    end

    it 'defines the artwork_tag helper method' do
      expect(View.instance_methods.map(&:to_sym)).to include(:artwork_tag)
    end
  end
end
