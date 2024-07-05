require 'tk'
require_relative '../calculators/bybit_calculator'
require_relative '../utilities/formatter'

module BybitCalculatorApp
  class InversePerpetualTab
    MARGIN_MODES = ['Isolated', 'Cross']
    POSITION_TYPES = ['Long', 'Short']

    def initialize(notebook)
      @calculator = BybitCalculator.new
      create_tab(notebook)
    end

    private

    def create_tab(notebook)
      tab = TkFrame.new(notebook)
      notebook.add(tab, text: 'Inverse Perpetual')

      inputs = [
        ['Quantity', 'quantity'],
        ['Entry Price (USD)', 'entry_price'],
        ['Leverage (1-100)', 'leverage'],
        ['Margin Mode', 'margin_mode', MARGIN_MODES],
        ['Position', 'position', POSITION_TYPES],
        ['Account Balance (BTC)', 'account_balance']
      ]

      @entry_widgets = create_input_fields(tab, inputs)
      @result_text = create_result_text(tab, inputs.length)

      create_calculate_button(tab, inputs.length)
    end

    def create_input_fields(tab, inputs)
      entry_widgets = {}
      inputs.each_with_index do |(label, key, options), index|
        TkLabel.new(tab) { text label; grid(row: index, column: 0, padx: 5, pady: 5, sticky: 'e') }
        
        if options
          variable = TkVariable.new
          TkOptionMenuButton.new(tab, variable, *options) { grid(row: index, column: 1, padx: 5, pady: 5, sticky: 'we') }
          entry_widgets[key] = variable
        else
          entry_widgets[key] = TkEntry.new(tab) { grid(row: index, column: 1, padx: 5, pady: 5, sticky: 'we') }
        end
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
        command { calculate_inverse_perpetual }
        grid(row: input_count, column: 0, columnspan: 2, padx: 5, pady: 5)
      end
    end

    def calculate_inverse_perpetual
      begin
        inputs = @entry_widgets.transform_values { |widget| widget.respond_to?(:get) ? widget.get : widget.value }
        quantity = inputs['quantity'].to_f
        entry_price = inputs['entry_price'].to_f
        leverage = inputs['leverage'].to_f
        margin_mode = inputs['margin_mode'].downcase.to_sym
        is_long = inputs['position'].downcase == 'long'
        account_balance = inputs['account_balance'].to_f

        raise ArgumentError, "Leverage must be between 1 and 100" unless (1..100).cover?(leverage)

        result = @calculator.calculate(quantity, entry_price, leverage, is_long, margin_mode, account_balance)
        @result_text.value = Formatter.format_result(result)
      rescue ArgumentError, TypeError => e
        @result_text.value = "Error: #{e.message}"
      rescue StandardError => e
        @result_text.value = "An unexpected error occurred: #{e.message}"
      end
    end
  end
end