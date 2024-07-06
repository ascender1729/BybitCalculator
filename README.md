
# ByBit Inverse BTCUSD Perpetual Calculator

Developed by Pavan Kumar, this Ruby-based application assists cryptocurrency traders in managing and calculating risks associated with ByBit's Inverse BTCUSD Perpetual contracts. It features various calculators and a user-friendly interface implemented with Tk and Ruby gems.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Project Overview

This desktop application is designed to help traders make informed decisions by providing detailed calculations for strategies such as averaging down and comparing different margin strategies.

## Features

- **Inverse Perpetual Calculator**: Compute liquidation and bankruptcy prices, and other metrics for both long and short positions.
- **Averaging Down Calculator**: Helps plan additional purchases as the BTC price declines, providing new average entry prices.
- **Strategy Comparison**: Allows comparison between different trading strategies like Isolated Margin and Cross Margin.

## Technologies Used

- **Programming Language**: Ruby
- **GUI Toolkit**: Tk
- **Ruby Gems**:
  - `tk` - For the GUI components.
  - `terminal-table` - To display tabular data in the terminal.
  - `minitest` - For running unit tests on the application.

## Project Structure

```
BybitCalculator/
│
├── assets/
│   └── cal.ico
│
├── lib/
│   ├── calculators/
│   │   ├── averaging_down.rb
│   │   ├── bybit_calculator.rb
│   │   └── strategy_comparison.rb
│   ├── gui/
│   │   ├── averaging_down_tab.rb
│   │   ├── inverse_perpetual_tab.rb
│   │   └── strategy_comparison_tab.rb
│   │   └── main_window.rb
│   └── utilities/
│       └── formatter.rb
│
├── test/
│   ├── calculator_test.rb
│   └── icon_test.rb
│
├── app.rb
├── Gemfile
├── Gemfile.lock
├── LICENSE
└── README.md
```

## Installation

Ensure Ruby is installed on your system (Ruby 2.7+ recommended):
1. Clone the repository:
   ```
   git clone https://github.com/ascender1729/BybitCalculator.git
   cd BybitCalculator
   ```
2. Install required Ruby gems:
   ```
   bundle install
   ```

## Usage

To launch the application:
```
ruby app.rb
```
Navigate through the tabs to access different calculators for various trading strategies.

## Contributing

Interested in contributing? Here's how you can help:
1. Fork the repository.
2. Create a new branch for your feature (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Submit a pull request.

## License

This project is released under the MIT License. See the `LICENSE` file for details.

## Contact

Pavan Kumar - pavankumard.pg19.ma@nitp.ac.in

LinkedIn: [linkedin.com/in/im-pavankumar](https://www.linkedin.com/in/im-pavankumar/)

Project Link: [github.com/ascender1729/BybitCalculator](https://github.com/ascender1729/BybitCalculator)
