require_relative 'helper'
require 'inkscape_merge/data_parsers'

RSpec.describe Inkscape::Merge::DataParser do
  before do
    @options = OpenStruct.new
    @options.csv_options = {:headers => true, :col_sep => ',', :encoding => 'utf-8'}
    @options.data_file = File.join(File.dirname(__FILE__), 'fixtures/data.csv')
  end

  it "returns a CSV parser" do
    data_file = Inkscape::Merge::DataParser.detect(@options)
    expect(data_file.class).to eq Inkscape::Merge::DataParser::CSV
  end

  it 'parses CSV headers' do
    data_file = Inkscape::Merge::DataParser.detect(@options)
    expect(data_file.headers).to eq ['Col1', 'Col2']
  end

  it 'parses CSV data rows' do
    data_file = Inkscape::Merge::DataParser.detect(@options)
    expect(data_file.each.map{|row| row['Col1']}).to eq ["1.0", "2.0"]
  end
end
