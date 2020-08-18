class SlowTest
  attr_reader :location, :example, :seconds

  def initialize(location:, example:, seconds:)
    @location = location
    @example = example
    @seconds = seconds.to_f
  end
end
