require 'tk'
require_relative 'lib/gui/main_window'

window = BybitCalculatorApp::MainWindow.new
window.run

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
    mm_btc = MAINTENANCE_MARGIN_RATE * quantity / entry_price
    if is_long
      (quantity * entry_price - account_balance) / (quantity / entry_price + mm_btc - quantity / entry_price)
    else
      (quantity * entry_price + account_balance) / (quantity / entry_price - mm_btc - quantity / entry_price)
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

class BybitCalculatorApp
  MARGIN_MODES = ['Isolated', 'Cross']
  POSITION_TYPES = ['Long', 'Short']

  def initialize
    @root = TkRoot.new { title "ByBit Inverse BTCUSD Perpetual Calculator" }
    @calculator = BybitCalculator.new
    @averaging_down = AveragingDown.new
    @strategy_comparison = StrategyComparison.new

    create_notebook
    create_inverse_perpetual_tab
    create_averaging_down_tab
    create_strategy_comparison_tab
  end

  def run
    Tk.mainloop
  end

  private

  def create_notebook
    @notebook = Tk::Tile::Notebook.new(@root) do
      pack(fill: 'both', expand: true)
    end
  end

  def create_inverse_perpetual_tab
    tab = TkFrame.new(@notebook)
    @notebook.add(tab, text: 'Inverse Perpetual')

    inputs = [
      ['Quantity', 'quantity', :entry],
      ['Entry Price (USD)', 'entry_price', :entry],
      ['Leverage (1-100)', 'leverage', :entry],
      ['Margin Mode', 'margin_mode', :dropdown, MARGIN_MODES],
      ['Position', 'position', :dropdown, POSITION_TYPES],
      ['Account Balance (BTC)', 'account_balance', :entry]
    ]

    entry_widgets = create_input_fields(tab, inputs)
    result_text = create_result_text(tab, inputs.length)

    create_calculate_button(tab, 'Calculate', inputs.length) do
      calculate_inverse_perpetual(entry_widgets, result_text)
    end
  end

  def create_averaging_down_tab
    tab = TkFrame.new(@notebook)
    @notebook.add(tab, text: 'Averaging Down')

    inputs = [
      ['Total Budget (USD)', 'budget', :entry],
      ['Current BTC Price (USD)', 'current_price', :entry],
      ['Target Average Price (USD)', 'target_price', :entry],
      ['Number of Additional Orders', 'num_orders', :entry]
    ]

    entry_widgets = create_input_fields(tab, inputs)
    result_text = create_result_text(tab, inputs.length)

    create_calculate_button(tab, 'Calculate', inputs.length) do
      calculate_averaging_down(entry_widgets, result_text)
    end
  end

  def create_strategy_comparison_tab
    tab = TkFrame.new(@notebook)
    @notebook.add(tab, text: 'Strategy Comparison')

    inputs = [
      ['Account Balance (BTC)', 'balance', :entry],
      ['Initial BTC Price (USD)', 'initial_price', :entry],
      ['Target Liquidation Price (USD)', 'target_liquidation', :entry]
    ]

    entry_widgets = create_input_fields(tab, inputs)
    result_text = create_result_text(tab, inputs.length)

    create_calculate_button(tab, 'Compare', inputs.length) do
      compare_strategies(entry_widgets, result_text)
    end
  end

  def create_input_fields(tab, inputs)
    entry_widgets = {}
    inputs.each_with_index do |(label, key, type, options), index|
      TkLabel.new(tab) { text label; grid(row: index, column: 0, padx: 5, pady: 5, sticky: 'e') }
      
      case type
      when :entry
        entry_widgets[key] = TkEntry.new(tab) { grid(row: index, column: 1, padx: 5, pady: 5, sticky: 'we') }
      when :dropdown
        variable = TkVariable.new
        entry_widgets[key] = variable
        TkOptionMenuButton.new(tab, variable, *options) { grid(row: index, column: 1, padx: 5, pady: 5, sticky: 'we') }
        variable.value = options.first # Set default value
      end
    end
    tab.grid_columnconfigure(1, weight: 1)
    entry_widgets
  end
  
  def create_result_text(tab, input_count)
    TkText.new(tab) do
      width 50
      height 15
      grid(row: input_count + 1, column: 0, columnspan: 2, padx: 5, pady: 5, sticky: 'nsew')
    end
  end

  def create_calculate_button(tab, text, input_count, &block)
    TkButton.new(tab) do
      text text
      command block
      grid(row: input_count, column: 0, columnspan: 2, padx: 5, pady: 5)
    end
  end

  def calculate_inverse_perpetual(entry_widgets, result_text)
    begin
      quantity = Float(entry_widgets['quantity'].get)
      entry_price = Float(entry_widgets['entry_price'].get)
      leverage = Float(entry_widgets['leverage'].get)
      margin_mode = entry_widgets['margin_mode'].value.downcase.to_sym
      is_long = entry_widgets['position'].value.downcase == 'long'
      account_balance = Float(entry_widgets['account_balance'].get)

      raise ArgumentError, "Leverage must be between 1 and 100" unless (1..100).cover?(leverage)

      result = @calculator.calculate(quantity, entry_price, leverage, is_long, margin_mode, account_balance)
      result_text.value = format_result(result)
    rescue ArgumentError, TypeError => e
      result_text.value = "Error: #{e.message}"
    rescue StandardError => e
      result_text.value = "An unexpected error occurred: #{e.message}"
    end
  end

  def calculate_averaging_down(entry_widgets, result_text)
    begin
      budget = Float(entry_widgets['budget'].get)
      current_price = Float(entry_widgets['current_price'].get)
      target_price = Float(entry_widgets['target_price'].get)
      num_orders = Integer(entry_widgets['num_orders'].get)

      result = @averaging_down.calculate(budget, current_price, target_price, num_orders)
      result_text.value = format_averaging_down_result(result)
    rescue ArgumentError, TypeError => e
      result_text.value = "Error: #{e.message}"
    rescue StandardError => e
      result_text.value = "An unexpected error occurred: #{e.message}"
    end
  end

  def compare_strategies(entry_widgets, result_text)
    begin
      balance = Float(entry_widgets['balance'].get)
      initial_price = Float(entry_widgets['initial_price'].get)
      target_liquidation = Float(entry_widgets['target_liquidation'].get)

      result = @strategy_comparison.compare(balance, initial_price, target_liquidation)
      result_text.value = format_strategy_comparison_result(result)
    rescue ArgumentError, TypeError => e
      result_text.value = "Error: #{e.message}"
    rescue StandardError => e
      result_text.value = "An unexpected error occurred: #{e.message}"
    end
  end

  def format_result(result)
    output = "Results:\n"
    output += "-" * 40 + "\n"
    result.each do |key, value|
      formatted_value = value.is_a?(Float) ? sprintf("%.8f", value) : value.to_s
      output += sprintf("%-20s: %s\n", key.to_s.capitalize.gsub('_', ' '), formatted_value)
    end
    output
  end

  def format_averaging_down_result(result)
    output = "Orders:\n"
    output += sprintf("%-4s %-15s %-20s %-15s\n", "No.", "Price (USD)", "Quantity (BTC)", "Amount (USD)")
    output += "-" * 60 + "\n"
    result[:orders].each_with_index do |order, index|
      output += sprintf("%-4d $%-14.2f %-20.8f $%-14.2f\n", 
                        index + 1, order[:price], order[:quantity], order[:amount])
    end
    output += "\n"
    output += sprintf("%-25s $%.2f\n", "Final average price:", result[:average_price])
    output += sprintf("%-25s %.8f BTC\n", "Total BTC:", result[:total_btc])
    output += sprintf("%-25s $%.2f\n", "Total spent:", result[:total_spent])
    output
  end

  def format_strategy_comparison_result(result)
    output = ""
    result.each do |strategy, data|
      output += "#{strategy.to_s.capitalize.gsub('_', ' ')}:\n"
      output += sprintf("  %-20s $%.2f\n", "Liquidation Price:", data[:liquidation_price])
      output += sprintf("  %-20s $%.2f\n", "Available Funds:", data[:available_funds])
      output += sprintf("  %-20s %dx\n\n", "Leverage:", data[:leverage])
    end
    output
  end
end

if __FILE__ == $PROGRAM_NAME
  BybitCalculatorApp.new.run
end