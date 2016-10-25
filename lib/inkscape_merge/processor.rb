require 'ostruct'
require 'tempfile'
require 'fileutils'
require 'inkscape_merge/data_parsers'
require 'shellwords'

module Inkscape # :nodoc:
  module Merge # :nodoc:
    # Main class to initialize processing
    class Processor
      attr_reader :options

      # Initialize the processor, setting files and options
      def initialize
        @options = OpenStruct.new
        # Default options
        @options.format = "pdf"
        @options.csv_options = {:headers => true, :col_sep => ',', :encoding => 'utf-8'}
        @options.limit = 0
        @options.dpi = 300
        @options.inkscape = %x(which inkscape).chomp
        # If no Inkscape in PATH, try to guess from platform
        if options.inkscape.empty?
          options.inkscape = case RUBY_PLATFORM
            when /darwin/
              "/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
            end
        end

      end

      # Iterate over all data rows and generate output files
      # Optionally stop when LIMIT is reached
      def run
        validate_options

        # Open the files
        @svg = File.read options.svg_file
        @data_file = DataParser.detect(options)

        count = 0
        headers = @data_file.headers
        pattern = /%VAR_(#{headers.map(&:to_s).join("|")})%/
        @data_file.each{|row|
          break if @options.limit > 0 && count >= @options.limit
          count += 1
          puts "Row: #{count}"
          tmp_file = Tempfile.new('inkscape_merge')
          begin
            (outfile,merged_svg) = [@options.output,@svg].map{|s|
                s.gsub(pattern){|m|
                  puts $1 if @options.verbose
                  # return corresponding value from current row
                  row[$1]
              }
            }

            # Write merged SVG out
            tmp_file.puts merged_svg
            tmp_file.close

            # Sprintf outfile with current row number
            outfile %= count

            # Generate output path
            FileUtils.mkdir_p(File.dirname outfile)

            # Generate the file itself
            ink_generate tmp_file.path, Shellwords.escape(outfile), @options.format, @options.dpi
          rescue => e
            $stderr.puts "ERROR: #{e}"
            $stderr.puts e.backtrace if @options.verbose
          ensure
            tmp_file.unlink
          end
        }
      end

      private

      # Validate options and give error if something is missing
      def validate_options
        # TODO: replace with

        # If inkscape can not be found or run, bail out
        unless File.executable? @options.inkscape
          raise ArgumentError, "Inkscape not found or not executable"
        end

        unless @options.svg_file
          raise ArgumentError, "SVG file must be given"
        end

        unless @options.data_file
          raise ArgumentError, "Data-file must be given"
        end

        unless @options.output
          raise ArgumentError, "Output pattern must be given"
        else
          # Ensure absolute pathname
          @options.output = File.absolute_path(@options.output)
        end
      end

      # Run Inkscape to generate files
      def ink_generate(in_file, out_file, format='pdf', dpi="300")
        cmd = %(#{@options.inkscape} --without-gui --export-#{format}=#{out_file} --export-dpi=#{dpi} #{in_file})
        puts "INKSCAPE CMD: #{cmd}" if @options.verbose
        ink_error = `#{cmd} 2>&1`
        unless $?.success?
          $stderr.puts "Inkscape ERROR (#{$?}): #{ink_error}"
        end
      end
    end
  end
end
