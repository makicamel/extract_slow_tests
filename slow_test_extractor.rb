require "pathname"
require "date"
require "csv"
require "./slow_test.rb"
require "./slow_test_collection.rb"

class SlowTestExtractor
  EXAMPLE_PATTERN = /Top (\d+) slowest examples/.freeze
  EXAMPLE_GROUP_PATTERN = /Top (\d+) slowest example groups:/.freeze
  TIME_PATTERN = %r{(\d+\.?\d*) seconds (\./spec/.*)}.freeze

  def initialize(file_name = "result.log")
    @log = File.read(Pathname.pwd + file_name)
    @collection = SlowTestCollection.new
  end

  # mode: :csv or :md
  def execute(directory = "results", mode: :csv)
    pos = 0
    @log.scan(EXAMPLE_PATTERN).size.times { |_| pos = extract_tests(pos) }

    path_name = Pathname.pwd + directory + "#{Date.today.strftime('%Y%m%d')}.#{mode}"
    if mode == :csv
      CSV.open(path_name, "w") do |csv|
        csv << %w[seconds example file]
        @collection.aggregate.each { |test| csv << test.to_a }
      end
    else
      File.open(path_name, "w") do |file|
        file.puts Date.today.strftime("%Y%m%d")
        file.puts @collection.aggregate.map.with_index(1) { |test, i| "#{i}. #{test}" }
      end
    end

    path_name
  end

  private

  def extract_tests(pos)
    first = @log.match(EXAMPLE_PATTERN, pos).end 0
    last = @log.match(EXAMPLE_GROUP_PATTERN, pos).begin 0
    specs = @log[first...last].split("\n").map(&:strip).reject { |match| match == "" }

    example = ""
    specs[1..].map.with_index(0) do |spec, i|
      if i.even?
        example = spec
      else
        data = spec.match(TIME_PATTERN)
        @collection.push(SlowTest.new(example: example, seconds: data[1], location: data[2]))
      end
    end
    last + 1
  end

  def profile_count
    @profile_count ||= @log.match(example_pattern)[1]
  end
end

path = SlowTestExtractor.new.execute(mode: :csv)

p "Extract finished. See #{path}"
