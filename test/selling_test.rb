# frozen_string_literal: true

require 'minitest/autorun'
require 'vending_machine'
require_relative 'fixtures/config_fixture'
require_relative 'test_helper'

class SellingTest < Minitest::Test
  PRODUCT = :coke

  def setup
    @config = ConfigFixture.config
    @state = Ready.new({ coke: 1 }, @config.zero_state[1]).pick(PRODUCT)
  end

  def test_initial_state
    assert_instance_of(Struct::Selling, @state)
    assert_equal(PRODUCT, @state.product)
    assert_predicate(@state.cash, :empty?)
  end

  def test_no_change
    @state.stub :config, @config do
      state, response = @state.put(100)
      assert_instance_of(Struct::Ready, state)
      assert_match(/could not find enough change/, response[:message])
      assert_equal({ 100 => 1 }, response[:return])
      assert_equal({ coke: 1 }, @state.inventory)
    end
  end

  def test_awaiting_more_coins
    @state.stub :config, @config do
      state, message = @state.put(50)
      assert_match(/Awaiting 3/, message)
      assert_equal({ 50 => 1 }, state.cash)
      assert_equal({ coke: 1 }, state.inventory)
    end
  end

  def test_timeout
    Timeout.stub :timeout, proc { raise Timeout::Error } do
      response = @state.receive
      assert_equal(:timed_out, response)
    end
  end

  def test_timed_out
    @state.cash = { 10 => 2 }
    state, response = @state.timed_out
    assert_match(/aborting now/, response[:message])
    assert_equal({ 10 => 2 }, response[:return])
    assert_instance_of(Struct::Ready, state)
  end

  def test_sell
    @state.till = { 100 => 1, 25 => 1, 10 => 1, 5 => 1, 1 => 10 }
    @state.cash = { 50 => 1, 5 => 1 }
    @state.stub :config, @config do
      state, response = @state.put(50)
      assert_match(/Enjoy your purchase/, response[:message])
      assert_equal_hash({ 100 => 0, 50 => 1, 25 => 0, 10 => 0, 5 => 0, 1 => 2 }, response[:return])
      assert_equal_hash({ 100 => 1, 50 => 1, 25 => 1, 10 => 1, 5 => 2, 1 => 8 }, state.till)
      assert_equal({ coke: 0 }, state.inventory)
      assert_instance_of(Struct::Ready, state)
    end
  end
end
