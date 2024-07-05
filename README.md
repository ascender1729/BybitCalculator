# ByBit Inverse BTCUSD Perpetual Calculator

## Table of Contents
1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Project Structure](#project-structure)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Contributing](#contributing)
7. [License](#license)
8. [Contact](#contact)

## Project Overview

The ByBit Inverse BTCUSD Perpetual Calculator is a Ruby-based desktop application that provides tools for cryptocurrency traders using ByBit's Inverse BTCUSD Perpetual contracts. It offers calculations for inverse perpetual contracts, averaging down strategies, and strategy comparisons to help traders make informed decisions.

## Features

1. **Inverse Perpetual Calculator**: 
   - Calculate liquidation price, bankruptcy price, and other key metrics
   - Support for both isolated and cross margin
   - Long and short position calculations

2. **Averaging Down Calculator**:
   - Plan additional purchases as BTC price declines
   - Calculate average entry price and total BTC acquired

3. **Strategy Comparison**:
   - Compare Averaging Down, Isolated Margin, and Cross Margin strategies
   - Determine the best approach for lowering liquidation price while maximizing available funds

4. **User-Friendly GUI**:
   - Built with Tk for a native look and feel
   - Tabbed interface for easy navigation between calculators

## Project Structure

```
bybit_calculator/
│
├── assets/
│   └── cal.ico
│
├── lib/
│   ├── calculators/
│   │   ├── bybit_calculator.rb
│   │   ├── averaging_down.rb
│   │   └── strategy_comparison.rb
│   ├── gui/
│   │   └── main_window.rb
│   └── utilities/
│       └── formatter.rb
│
├── test/
│   └── calculator_test.rb
│
├── app.rb
├── Gemfile
├── Gemfile.lock
└── README.md
```

## Installation

1. Ensure you have Ruby installed on your system (version 2.7.0 or higher recommended).
2. Clone this repository:
   ```
   git clone https://github.com/ascender1729/BybitCalculator.git
   cd BybitCalculator
   ```
3. Install the required gems:
   ```
   bundle install
   ```

## Usage

To run the application:

```
ruby app.rb
```

The application window will open with three tabs:

1. **Inverse Perpetual**: Enter your position details to calculate liquidation price and other metrics.
2. **Averaging Down**: Plan your averaging down strategy by entering your budget and target prices.
3. **Strategy Comparison**: Compare different margin strategies by entering your account balance and price targets.

## Contributing

Contributions to the ByBit Inverse BTCUSD Perpetual Calculator are welcome! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please ensure your code adheres to the existing style and includes appropriate tests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contact

Your Name - your.email@example.com

Project Link: [https://github.com/ascender1729/BybitCalculator](https://github.com/ascender1729/BybitCalculator)

