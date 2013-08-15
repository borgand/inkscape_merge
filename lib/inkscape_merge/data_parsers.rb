require 'csv'
if CSV.const_defined? :Reader
  # Ruby 1.8 compatible
  require 'fastercsv'
  Object.send(:remove_const, :CSV)
  CSV = FasterCSV
else
  # CSV is now FasterCSV in ruby 1.9
end


# Module to detect and wrap data-files
module Inkscape # :nodoc:
  module Merge # :nodoc:
    module DataParser
  
      # Detect, which parser to use for given input file
      def self.detect(options)
        case options.data_file
        when /.csv$/i
          return ::Inkscape::Merge::DataParser::CSV.new(options.data_file, options.csv_options)
        end
      end

      # CSV file parser
      # Though Ruby's CSV would suffice, we explicitly wrap it in an API
      # Other parsers must comply to this API
      class CSV
        include Enumerable
    
        # Read file into memory
        def initialize(data_file, csv_options)
          opts = csv_options
          @data = ::CSV.read data_file, opts
        end
    
        # Return headers as an array
        def headers
          @data.headers
        end
    
        # Wraps CSV#each for enumerable support
        def each(&block)
          @data.each &block
        end
      end
    end
  end
end