require 'tk'
require_relative '../calculators/bybit_calculator'
require_relative '../calculators/averaging_down'
require_relative '../calculators/strategy_comparison'
require_relative '../utilities/formatter'

module BybitCalculatorApp
  class MainWindow
    MARGIN_MODES = ['Isolated', 'Cross']
    POSITION_TYPES = ['Long', 'Short']

    def initialize
      @root = TkRoot.new { title "ByBit Inverse BTCUSD Perpetual Calculator" }
      set_custom_icon
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

    def set_custom_icon
      icon_path = File.join(File.dirname(__FILE__), '..', '..', 'assets', 'cal.ico')
      if File.exist?(icon_path)
        begin
          @root.wm_iconbitmap(icon_path)
          puts "Icon successfully set from: #{icon_path}"
        rescue StandardError => e
          puts "Error setting icon: #{e.message}"
        end
      else
        puts "Warning: Icon file not found at #{icon_path}"
      end
    end

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
        width 80
        height 20
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
        inputs = entry_widgets.transform_values { |widget| widget.respond_to?(:get) ? widget.get : widget.value }
        result = @calculator.calculate(
          inputs['quantity'].to_f,
          inputs['entry_price'].to_f,
          inputs['leverage'].to_f,
          inputs['position'].downcase == 'long',
          inputs['margin_mode'].downcase.to_sym,
          inputs['account_balance'].to_f
        )
        result_text.value = Formatter.format_result(result)
      rescue ArgumentError, TypeError => e
        result_text.value = "Error: #{e.message}"
      rescue StandardError => e
        result_text.value = "An unexpected error occurred: #{e.message}"
      end
    end

    def calculate_averaging_down(entry_widgets, result_text)
      begin
        inputs = entry_widgets.transform_values(&:get)
        result = @averaging_down.calculate(
          inputs['budget'].to_f,
          inputs['current_price'].to_f,
          inputs['target_price'].to_f,
          inputs['num_orders'].to_i
        )
        result_text.value = Formatter.format_averaging_down_result(result)
      rescue ArgumentError, TypeError => e
        result_text.value = "Error: #{e.message}"
      rescue StandardError => e
        result_text.value = "An unexpected error occurred: #{e.message}"
      end
    end

    def compare_strategies(entry_widgets, result_text)
      begin
        inputs = entry_widgets.transform_values(&:get)
        result = @strategy_comparison.compare(
          inputs['balance'].to_f,
          inputs['initial_price'].to_f,
          inputs['target_liquidation'].to_f
        )
        result_text.value = Formatter.format_strategy_comparison_result(result)
      rescue ArgumentError, TypeError => e
        result_text.value = "Error: #{e.message}"
      rescue StandardError => e
        result_text.value = "An unexpected error occurred: #{e.message}"
      end
    end
  end
end