class AveragingDown
  def calculate(budget, current_price, target_price, num_orders)
    validate_inputs(budget, current_price, target_price, num_orders)

    initial_quantity = budget / current_price
    remaining_budget = budget
    total_quantity = initial_quantity
    orders = []

    price_step = (current_price - target_price) / (num_orders + 1.0) # Ensure float division

    (1..num_orders).each do |i|
      order_price = [current_price - (i * price_step), 0.01].max
      order_quantity = remaining_budget / ((num_orders - i + 1.0) * order_price) # Ensure float division
      order_amount = order_quantity * order_price

      orders << {
        price: order_price.round(2),
        quantity: order_quantity.round(8),
        amount: order_amount.round(2)
      }

      total_quantity += order_quantity
      remaining_budget -= order_amount
    end

    average_price = budget / total_quantity

    {
      orders: orders,
      average_price: average_price.round(2),
      total_btc: total_quantity.round(8),
      total_spent: budget.round(2)
    }
  end

  private

  def validate_inputs(budget, current_price, target_price, num_orders)
    raise ArgumentError, "Budget must be positive" unless budget.positive?
    raise ArgumentError, "Current price must be positive" unless current_price.positive?
    raise ArgumentError, "Target price must be positive" unless target_price.positive?
    raise ArgumentError, "Target price must be less than current price" unless target_price < current_price
    raise ArgumentError, "Number of orders must be positive" unless num_orders.positive?
  end
end
