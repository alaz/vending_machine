# frozen_string_literal: true

class Minitest::Test
  def assert_equal_hash(expected, actual)
    assert_equal expected.sort.reverse.to_h, actual.sort.reverse.to_h
  end
end
