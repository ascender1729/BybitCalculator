require 'tk'
require_relative '../calculators/strategy_comparison'
require_relative '../utilities/formatter'

module BybitCalculatorApp
  class StrategyComparisonTab
    def initialize(notebook)
      @strategy_comparison = StrategyComparison.new
      create_tab(notebook)
    end

    private

    def create_tab(notebook)
      tab = TkFrame.new(notebook)
      notebook.add(tab, text: 'Strategy Comparison')

      inputs = [
        ['Account Balance (BTC)', 'balance'],
        ['Initial BTC Price (USD)', 'initial_price'],
        ['Target Liquidation Price (USD)', 'target_liquidation']
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
        text 'Compare'
        command { compare_strategies }
        grid(row: input_count, column: 0, columnspan: 2, padx: 5, pady: 5)
      end
    end

    def compare_strategies
      begin
        inputs = @entry_widgets.transform_values(&:get)
        result = @strategy_comparison.compare(
          inputs['balance'].to_f,
          inputs['initial_price'].to_f,
          inputs['target_liquidation'].to_f
        )
        @result_text.value = Formatter.format_strategy_comparison_result(result)
      rescue ArgumentError, TypeError => e
        @result_text.value = "Error: #{e.message}"
      rescue StandardError => e
        @result_text.value = "An unexpected error occurred: #{e.message}"
      end
    end
  end
end