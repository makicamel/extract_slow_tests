require "forwardable"

class SlowTestCollection
  extend Forwardable
  def_delegators :@tests, :push, :sort, :reverse, :map

  def initialize
    @tests = []
  end

  def aggregate
    @tests.sort_by { |test| test.seconds }.reverse
  end
end
