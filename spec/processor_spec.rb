require_relative 'helper'

RSpec.describe Inkscape::Merge::Processor do
  before do
    @processor = Inkscape::Merge::Processor.new
    @processor.options.csv_options = {:headers => true, :col_sep => ',', :encoding => 'utf-8'}
    @processor.options.data_file = File.join(File.dirname(__FILE__), 'fixtures/data.csv')
    @processor.options.svg_file = File.join(File.dirname(__FILE__), 'fixtures/test.svg')
    @processor.options.inkscape = File.join(File.dirname(__FILE__), 'fixtures/fake_inkscape')
    @processor.options.output = File.join(File.dirname(__FILE__), 'fixtures/output_%d.svg')
  end

  context 'When validating options' do
    it "validates inkscape binary" do
      @processor.options.inkscape = 'nonexistant'
      expect{@processor.send(:validate_options)}.to raise_error(ArgumentError, 'Inkscape not found or not executable')
    end

    it "validates svg file" do
      @processor.options.svg_file = nil
      expect{@processor.send(:validate_options)}.to raise_error(ArgumentError, 'SVG file must be given')
    end

    it "validates data file" do
      @processor.options.data_file = nil
      expect{@processor.send(:validate_options)}.to raise_error(ArgumentError, 'Data-file must be given')
    end

    it "validates inkscape binary" do
      @processor.options.output = nil
      expect{@processor.send(:validate_options)}.to raise_error(ArgumentError, 'Output pattern must be given')
    end
  end

  context 'When generating' do
    it "calls ink_generate right number of times" do
      expect(@processor).to receive(:ink_generate).twice
      @processor.run
    end
  end
end
