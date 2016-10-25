require_relative 'helper'
require 'inkscape_merge/data_parsers'

class TestInkscapeMerge < Test::Unit::TestCase
  context "Parsing CSV files" do
    setup do
      @csv_file = Tempfile.open(['inkscape_merge_test', '.csv'])
      @csv_file.write %("Col1","Col2"\n1.0,"Hello")
      @csv_file.close

      @options = OpenStruct.new
      @options.csv_options = {:headers => true, :col_sep => ',', :encoding => 'utf-8'}
      @options.data_file = @csv_file.path
    end

    teardown do
      @csv_file.unlink
    end

    should "parse CSV file correctly" do
      data_file = Inkscape::Merge::DataParser.detect(@options)
      assert_equal 1, data_file.count
    end
  end
end
