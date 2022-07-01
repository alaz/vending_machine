# frozen_string_literal: true

require 'timeout'

module AbstractState # :nodoc:
  def dump
    [self, deconstruct_keys(members).merge(config:, state:)]
  end

  def receive
    Ractor.receive
  end

  def state
    self.class.name.split('::').last.downcase.to_sym
  end

  protected

  def config
    Ractor.current[:config]
  end
end

Ready = Struct.new 'Ready', :inventory, :till do
  include AbstractState

  def maintenance
    Disabled.new inventory, till
  end

  def pick(product)
    return [self, "Incorrect product #{product}"] unless inventory.key?(product)
    return [self, 'Out of stock'] if inventory[product].zero?

    Selling.new inventory, till, product, Hash.new(0)
  end
end

Disabled = Struct.new 'Disabled', :inventory, :till do
  include AbstractState

  def replace_till(new_till)
    self.till = new_till
    self
  end

  def replace_inventory(new_inventory)
    self.inventory = new_inventory
    self
  end

  def operate
    Ready.new inventory, till
  end
end

Selling = Struct.new 'Selling', :inventory, :till, :product, :cash do
  include AbstractState

  def put(coin)
    cash[coin] = cash[coin] + 1
    return [self, "Awaiting #{left_to_pay}"] if money < price

    whole_bank = till.merge(cash) { |_, c1, c2| c1 + c2 }
    still_to_return, coins_to_return = calculate_change whole_bank, money_to_return
    return reply 'Sorry, we could not find enough change, returning your coins' unless still_to_return.zero?

    inventory[product] = inventory[product] - 1
    self.till = whole_bank.merge(coins_to_return) { |_, c1, c2| c1 - c2 }
    reply 'Enjoy your purchase! Please do not forget your change', to_return: coins_to_return
  end

  def abort
    reply 'No problem, please come back. Do not forget your money!'
  end

  def timed_out
    reply 'We have waited for too long, aborting now. Do not forget your money!'
  end

  def receive
    Timeout.timeout(30) { Ractor.receive }
  rescue Timeout::Error
    :timed_out
  end

  private

  def reply(message, to_return: nil)
    [
      Ready.new(inventory, till),
      {
        message:,
        return: to_return || cash
      }
    ]
  end

  def calculate_change(bank, to_return)
    coins_to_return = {}
    still_to_return = config.denominations.inject(to_return) do |left_to_return, denomination|
      c = [left_to_return / denomination, bank[denomination]].min
      coins_to_return[denomination] = c
      left_to_return - c * denomination
    end
    [still_to_return, coins_to_return]
  end

  def price
    config.prices[product]
  end

  def money
    cash.map { |denomination, count| denomination * count }.sum
  end

  def left_to_pay
    price - money
  end

  def money_to_return
    money - price
  end
end

# prices: {product_id -> price as int}
# denominations: [in cents]
VendingMachine = Struct.new :prices, :denominations do
  def initialize(prices, denominations)
    super
    normalize_denominations
  end

  def create(display: nil)
    Ractor.new [display || default_display, self, *zero_state] do |display, config, *initial_state|
      machine_methods = {
        accepted_coins: proc { config.denominations },
        prices: proc { config.prices }
      }

      Ractor.current[:config] = config
      state = Ready.new(*initial_state)
      loop do
        display << "The vending machine is #{state.state}"
        Timeout.timeout 60 do
          msg = state.receive
          next display << machine_methods[msg].call if machine_methods.include? msg

          msg = [msg] unless msg.is_a? Array
          next display << "Unsupported method `#{msg[0]}`" unless state.respond_to? msg[0]

          state = state.send(*msg)
          if state.is_a? Array
            state, reply = state
            display << reply
          end
        end
      rescue Timeout::Error
        # Occasional touting
        display << 'Hiya, do you need anything?'
      end
    end
  end

  def zero_state
    inventory = prices.transform_values { 0 }
    till = denominations.to_h { |d| [d, 0] }
    [inventory, till]
  end

  private

  def normalize_denominations
    denominations.sort!
    denominations.reverse!
  end

  def default_display
    Ractor.new do
      loop do
        puts Ractor.receive
      end
    end
  end
end
