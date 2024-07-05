class StrategyComparison
  MAINTENANCE_MARGIN_RATE = 0.005 # 0.5%

  def compare(balance, initial_price, target_liquidation)
    validate_inputs(balance, initial_price, target_liquidation)

    averaging_down = calculate_averaging_down(balance, initial_price, target_liquidation)
    isolated_margin = calculate_isolated_margin(balance, initial_price, target_liquidation)
    cross_margin = calculate_cross_margin(balance, initial_price, target_liquidation)

    {
      averaging_down: averaging_down,
      isolated_margin: isolated_margin,
      cross_margin: cross_margin
    }
  end

  private

  def validate_inputs(balance, initial_price, target_liquidation)
    raise ArgumentError, "Balance must be positive" unless balance.positive?
    raise ArgumentError, "Initial price must be positive" unless initial_price.positive?
    raise ArgumentError, "Target liquidation price must be positive" unless target_liquidation.positive?
    raise ArgumentError, "Target liquidation price must be less than initial price" unless target_liquidation < initial_price
  end

  def calculate_averaging_down(balance, initial_price, target_liquidation)
    position_value = balance * initial_price
    additional_investment = position_value * 0.5
    new_balance = balance + (additional_investment / initial_price)
    new_average_price = (position_value + additional_investment) / new_balance
    leverage = (new_average_price / (new_average_price - target_liquidation)).ceil

    {
      liquidation_price: target_liquidation.round(2),
      available_funds: (position_value - additional_investment).round(2),
      leverage: leverage
    }
  end

  def calculate_isolated_margin(balance, initial_price, target_liquidation)
    position_value = balance * initial_price
    leverage = (initial_price / (initial_price - target_liquidation)).ceil
    initial_margin = position_value / leverage
    available_funds = position_value - initial_margin

    {
      liquidation_price: target_liquidation.round(2),
      available_funds: available_funds.round(2),
      leverage: leverage
    }
  end

  def calculate_cross_margin(balance, initial_price, target_liquidation)
    position_value = balance * initial_price
    leverage = (initial_price / (initial_price - target_liquidation)).ceil
    mm_btc = MAINTENANCE_MARGIN_RATE * balance
    available_funds = position_value * (1 - mm_btc)

    {
      liquidation_price: target_liquidation.round(2),
      available_funds: available_funds.round(2),
      leverage: leverage
    }
  end
end

# Example usage (uncomment to test):
# if __FILE__ == $PROGRAM_NAME
#   comparison = StrategyComparison.new
#   result = comparison.compare(1, 50000, 25000)
#   puts "Averaging Down: #{result[:averaging_down]}"
#   puts "Isolated Margin: #{result[:isolated_margin]}"
#   puts "Cross Margin: #{result[:cross_margin]}"
# end
