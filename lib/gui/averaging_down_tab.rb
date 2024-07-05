require 'tk'
require_relative '../calculators/averaging_down'
require_relative '../utilities/formatter'

module BybitCalculatorApp
  class AveragingDownTab
    def initialize(notebook)
      @averaging_down = AveragingDown.new
      create_tab(notebook)
    end

    private

    def create_tab(notebook)
      tab = TkFrame.new(notebook)
      notebook.add(tab, text: 'Averaging Down')

      inputs = [
        ['Total Budget (USD)', 'budget'],
        ['Current BTC Price (USD)', 'current_price'],
        ['Target Average Price (USD)', 'target_price'],
        ['Number of Additional Orders', 'num_orders']
      ]

      @entry_widgets = create_input_fields(tab, inputs)
      @result_text = create_result_text(tab, inputs.length)

      create_calculate_button(tab, inputs.length)
    end

    def create_input_fields(tab, inputs)
      entry_widgets = {}
      inputs.each_with_index do |(label, key), index|
        TkLabel.new(tab) { text label; grid(row: index, column: 0, padx: 5, pady: 5, sticky: 'e') }
        entry_widgets[key] = TkEntry.new(tab) { grid(row: index, column: 1, padx: 5, pady: 5, sticky: 'we') }
      end
      tab.grid_columnconfigure(1, weight: 1)
      entry_widgets
    end

    def create_result_text(tab, input_count)
      TkText.new(tab) do
        width 80
        height 20
        grid(row: input_count + 1, column: 0, columnspan: 2, padx: 5, pady: 5, sticky: 'nsew')
      end
    end

    def create_calculate_button(tab, input_count)
      TkButton.new(tab) do
        text 'Calculate'
        command { calculate_averaging_down }
        grid(row: input_count, column: 0, columnspan: 2, padx: 5, pady: 5)
      end
    end

    def calculate_averaging_down
      begin
        inputs = @entry_widgets.transform_values(&:get)
        result = @averaging_down.calculate(
          inputs['budget'].to_f,
          inputs['current_price'].to_f,
          inputs['target_price'].to_f,
          inputs['num_orders'].to_i
        )
        @result_text.value = Formatter.format_averaging_down_result(result)
      rescue ArgumentError, TypeError => e
        @result_text.value = "Error: #{e.message}"
      rescue StandardError => e
        @result_text.value = "An unexpected error occurred: #{e.message}"
      end
    end
  end
end

# The AveragingDown calculator class
class AveragingDown
  def calculate(budget, current_price, target_price, num_orders)
    validate_inputs(budget, current_price, target_price, num_orders)

    initial_quantity = budget / current_price
    remaining_budget = budget
    total_quantity = initial_quantity
    orders = []

    price_step = (current_price - target_price) / (num_orders + 1)

    (1..num_orders).each do |i|
      order_price = [current_price - (i * price_step), 0.01].max
      order_quantity = (remaining_budget / (num_orders - i + 1)) / order_price
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

# The Formatter module for output formatting
module Formatter
  def self.format_averaging_down_result(result)
    orders_table = Terminal::Table.new do |t|
      t.title = "Averaging Down Orders"
      t.headings = ['No.', 'Price (USD)', 'Quantity (BTC)', 'Amount (USD)']
      result[:orders].each_with_index do |order, index|
        t << [index + 1, format_value(order[:price]), format_value(order[:quantity]), format_value(order[:amount])]
      end
    end

    summary_table = Terminal::Table.new do |t|
      t.title = "Summary"
      t.add_row ["Final average price", format_value(result[:average_price])]
      t.add_row ["Total BTC", format_value(result[:total_btc])]
      t.add_row ["Total spent", format_value(result[:total_spent])]
    end

    "#{orders_table}\n\n#{summary_table}"
  end

  private

  def self.format_value(value)
    case value
    when Float then format('%.8f', value)
    else value.to_s
    end
  end
end