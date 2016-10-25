require_relative 'helper'
require 'inkscape_merge/data_parsers'

describe Inkscape::Merge::DataParser do
  describe "When parsing CSV files" do
    before do
      @csv_file = Tempfile.open(['inkscape_merge_test', '.csv'])
      @csv_file.write %("Col1","Col2"\n1.0,"Hello")
      @csv_file.close

      @options = OpenStruct.new
      @options.csv_options = {:headers => true, :col_sep => ',', :encoding => 'utf-8'}
      @options.data_file = @csv_file.path
    end

    after do
      @csv_file.unlink
    end

    it "returns a CSV parser" do
      data_file = Inkscape::Merge::DataParser.detect(@options)
      data_file.class.must_equal Inkscape::Merge::DataParser::CSV
    end
  end
end
