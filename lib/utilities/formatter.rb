require 'terminal-table'

module BybitCalculatorApp
  module Formatter
    def self.format_result(result)
      Terminal::Table.new do |t|
        t.title = "Calculation Results"
        result.each do |key, value|
          t << [key.to_s.capitalize.gsub('_', ' '), format_value(value)]
        end
      end
    end

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

    def self.format_strategy_comparison_result(result)
      Terminal::Table.new do |t|
        t.title = "Strategy Comparison"
        t.headings = ['Strategy', 'Liquidation Price', 'Available Funds', 'Leverage']
        result.each do |strategy, data|
          t << [
            strategy.to_s.capitalize.gsub('_', ' '),
            format_value(data[:liquidation_price]),
            format_value(data[:available_funds]),
            "#{data[:leverage]}x"
          ]
        end
      end
    end

    def self.format_value(value)
      case value
      when Float
        sprintf('%.8f', value)
      when Integer
        value.to_s
      else
        value.to_s
      end
    end

    def self.format_table(data, title: nil, headings: nil)
      Terminal::Table.new do |t|
        t.title = title if title
        t.headings = headings if headings
        data.each { |row| t << row }
      end
    end

    def self.format_tabular_result(result)
      rows = result.map do |key, value|
        [key.to_s.capitalize.gsub('_', ' '), format_value(value)]
      end
      format_table(rows, title: "Calculation Results")
    end
  end
end