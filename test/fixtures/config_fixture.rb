# frozen_string_literal: true

module ConfigFixture
  def self.config
    VendingMachine.new({ coke: 53 }, [1, 5, 10, 25, 50, 100])
  end
end
