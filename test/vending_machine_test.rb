# frozen_string_literal: true

require 'minitest/autorun'
require 'vending_machine'
require_relative 'fixtures/config_fixture'

class VendingMachineTest < Minitest::Test
  def setup
    @config = ConfigFixture.config
  end

  def test_denominations
    assert(@config.denominations.each_cons(2).all? { |a, b| a > b }, 'denominations are reverse sorted')
  end

  def test_zero_state_inventory
    z = @config.zero_state
    assert_equal(@config.prices.keys, z[0].keys)
    assert(z[0].values.all?(&:zero?), 'empty inventory')
  end

  def test_zero_state_till
    z = @config.zero_state
    assert_equal(@config.denominations.sort, z[1].keys.sort)
    assert(z[1].values.all?(&:zero?), 'empty till')
  end
end
