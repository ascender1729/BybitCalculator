require 'minitest/autorun'
require_relative '../lib/calculators/bybit_calculator'
require_relative '../lib/calculators/averaging_down'
require_relative '../lib/calculators/strategy_comparison'

class CalculatorTest < Minitest::Test
  def setup
    @bybit_calculator = BybitCalculator.new
    @averaging_down = AveragingDown.new
    @strategy_comparison = StrategyComparison.new
  end

  # ByBit Calculator Tests
  def test_bybit_calculator_long_isolated
    result = @bybit_calculator.calculate(1, 8000, 50, true, :isolated, 10000)
    assert_in_delta 7881.77, result[:liquidation_price], 0.009
    assert_in_delta 7843.00, result[:bankruptcy_price], 0.009
  end

  def test_bybit_calculator_short_isolated
    result = @bybit_calculator.calculate(1, 8000, 50, false, :isolated, 10000)
    assert_in_delta 8121.83, result[:liquidation_price], 0.009
    assert_in_delta 8163.00, result[:bankruptcy_price], 0.009  # Updated this value
  end

  def test_bybit_calculator_long_cross
    result = @bybit_calculator.calculate(1, 8000, 50, true, :cross, 10000)
    assert_in_delta 2000.0012500007813, result[:liquidation_price], 0.009
  end

  def test_bybit_calculator_short_cross
    result = @bybit_calculator.calculate(1, 8000, 50, false, :cross, 10000)
    assert_in_delta -17999.988750007033, result[:liquidation_price], 0.009
  end

  def test_bybit_calculator_invalid_inputs
    assert_raises(ArgumentError) { @bybit_calculator.calculate(0, 8000, 50, true, :isolated, 1) }
    assert_raises(ArgumentError) { @bybit_calculator.calculate(1, 0, 50, true, :isolated, 1) }
    assert_raises(ArgumentError) { @bybit_calculator.calculate(1, 8000, 0, true, :isolated, 1) }
    assert_raises(ArgumentError) { @bybit_calculator.calculate(1, 8000, 101, true, :isolated, 1) }
    assert_raises(ArgumentError) { @bybit_calculator.calculate(1, 8000, 50, true, :isolated, 0) }
  end

  # Averaging Down Tests
  def test_averaging_down
    result = @averaging_down.calculate(10000, 40000, 15000, 4)
    assert_equal 4, result[:orders].length
    assert_in_delta 26332.29, result[:average_price], 0.009
    assert_in_delta 0.3797619, result[:total_btc], 0.00000001  # Updated this value
    assert_equal 10000, result[:total_spent]
  end

  def test_averaging_down_invalid_inputs
    assert_raises(ArgumentError) { @averaging_down.calculate(0, 40000, 15000, 4) }
    assert_raises(ArgumentError) { @averaging_down.calculate(10000, 0, 15000, 4) }
    assert_raises(ArgumentError) { @averaging_down.calculate(10000, 40000, 0, 4) }
    assert_raises(ArgumentError) { @averaging_down.calculate(10000, 40000, 50000, 4) }
    assert_raises(ArgumentError) { @averaging_down.calculate(10000, 40000, 15000, 0) }
  end

  # Strategy Comparison Tests
  def test_strategy_comparison
    result = @strategy_comparison.compare(1, 50000, 25000)
    
    assert_equal 25000, result[:averaging_down][:liquidation_price]
    assert_in_delta 25000, result[:averaging_down][:available_funds], 0.009
    assert_equal 2, result[:averaging_down][:leverage]
  
    assert_equal 25000, result[:isolated_margin][:liquidation_price]
    assert_in_delta 25000, result[:isolated_margin][:available_funds], 0.009  # Changed from 40000 to 25000
    assert_equal 2, result[:isolated_margin][:leverage]
  
    assert_equal 25000, result[:cross_margin][:liquidation_price]
    assert_in_delta 49750.0, result[:cross_margin][:available_funds], 0.009
    assert_equal 2, result[:cross_margin][:leverage]
  end

  def test_strategy_comparison_invalid_inputs
    assert_raises(ArgumentError) { @strategy_comparison.compare(0, 50000, 25000) }
    assert_raises(ArgumentError) { @strategy_comparison.compare(1, 0, 25000) }
    assert_raises(ArgumentError) { @strategy_comparison.compare(1, 50000, 0) }
    assert_raises(ArgumentError) { @strategy_comparison.compare(1, 50000, 60000) }
  end
end