class SlowTest
  attr_reader :seconds

  def initialize(location:, example:, seconds:)
    @location = location
    @example = example
    @seconds = seconds.to_f
  end

  def to_a
    [@seconds, @example, @location]
  end

  def to_s
    "#{@seconds}s #{@example} #{@location}"
  end
end
