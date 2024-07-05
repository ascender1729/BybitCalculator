class BybitCalculator
  MAINTENANCE_MARGIN_RATE = 0.005 # 0.5%

  def calculate(quantity, entry_price, leverage, is_long, margin_mode, account_balance)
    validate_inputs(quantity, entry_price, leverage, account_balance)

    contract_value = quantity * entry_price
    order_margin = contract_value / leverage
    maintenance_margin = contract_value * MAINTENANCE_MARGIN_RATE

    liquidation_price = calculate_liquidation_price(quantity, entry_price, leverage, is_long, margin_mode, account_balance)
    bankruptcy_price = calculate_bankruptcy_price(entry_price, leverage, is_long, margin_mode)

    {
      quantity: quantity,
      entry_price: entry_price,
      leverage: leverage,
      contract_value: contract_value,
      order_margin: order_margin,
      maintenance_margin: maintenance_margin,
      liquidation_price: liquidation_price,
      bankruptcy_price: bankruptcy_price
    }
  end

  private

  def validate_inputs(quantity, entry_price, leverage, account_balance)
    raise ArgumentError, "Quantity must be positive" unless quantity.positive?
    raise ArgumentError, "Entry price must be positive" unless entry_price.positive?
    raise ArgumentError, "Leverage must be between 1 and 100" unless (1..100).cover?(leverage)
    raise ArgumentError, "Account balance must be positive" unless account_balance.positive?
  end

  def calculate_liquidation_price(quantity, entry_price, leverage, is_long, margin_mode, account_balance)
    if margin_mode == :isolated
      calculate_isolated_liquidation_price(entry_price, leverage, is_long)
    else
      calculate_cross_liquidation_price(quantity, entry_price, leverage, account_balance, is_long)
    end
  end

  def calculate_isolated_liquidation_price(entry_price, leverage, is_long)
    if is_long
      (entry_price * leverage) / (leverage + 1 - (MAINTENANCE_MARGIN_RATE * leverage))
    else
      (entry_price * leverage) / (leverage - 1 + (MAINTENANCE_MARGIN_RATE * leverage))
    end
  end

  def calculate_cross_liquidation_price(quantity, entry_price, leverage, account_balance, is_long)
    contract_value = quantity * entry_price
    mm_btc = MAINTENANCE_MARGIN_RATE * quantity / entry_price
    if is_long
      (contract_value - account_balance) / (quantity / entry_price + mm_btc - contract_value / entry_price)
    else
      (contract_value + account_balance) / (quantity / entry_price - mm_btc - contract_value / entry_price)
    end
  end

  def calculate_bankruptcy_price(entry_price, leverage, is_long, margin_mode)
    if margin_mode == :isolated
      if is_long
        (entry_price * leverage / (leverage + 1)).ceil(1)
      else
        (entry_price * leverage / (leverage - 1)).floor(1)
      end
    else
      if is_long
        entry_price * (1 - 1 / leverage)
      else
        entry_price * (1 + 1 / leverage)
      end
    end
  end
end
