require 'binance'
require 'bigdecimal'
require 'bigdecimal/util'
require './lib/coin_market_cap'

class BinanceWrapper

  # attr_reader :client
  def initialize
    puts "API key:"
    api_key = gets.chomp
    puts "API secret:"
    api_secret = gets.chomp
    @client = Binance::Client::REST.new api_key: api_key, secret_key: api_secret
    @exchange_info = @client.exchange_info["symbols"]
    @coin_market_cap = CoinMarketCap.new

    @alt_symbols = {
      "BCC" => "BCH",
      "IOTA" => "MIOTA"
    }
  end

  def ping
    @client.ping
  end

  def balances
    holdings = @client.account_info["balances"].select{ |position| BigDecimal.new(position["free"]) > 0 }
    holdings.each do |position|
      ticker = @alt_symbols[position["asset"]] || position["asset"]
      if @coin_market_cap.quote(ticker)
        position["price"] = @coin_market_cap.quote(ticker)["quotes"]["USD"]["price"]
        position["mkt_val"] = position["price"].to_d * position["free"].to_d
      end
    end
  end

  def order_book(pair)
    @client.book_ticker({symbol: pair})
  end

  def sell(opts={})
    # example:
    #   opts = {
    #     symbol: "XRPETH",  # buy XRP with ETH
    #     side: "SELL",
    #     type: "MARKET",
    #     quantity: 100
    #   }
    opts[:side] = "SELL"
    opts[:type] = opts[:type] || "MARKET"
    opts[:quantity] = order_size(opts[:symbol], opts[:quantity])
    @client.create_order! symbol: opts[:symbol], side: opts[:side], type: opts[:type], quantity: opts[:quantity]
  end

  def info(pair)
    @exchange_info.detect{ |info| info["symbol"] == pair }
  end

  def step_size(pair)
    info = info(pair)
    info["filters"].detect{ |filter| filter["filterType"] == "LOT_SIZE"}["stepSize"] if info
  end

  def order_size(pair, amount)
    # recalculate amount to fit step size constraint for a given pair
    amount = BigDecimal.new(amount)
    info = info(pair)
    if info
      step_size = BigDecimal.new(info["filters"].detect{ |filter| filter["filterType"] == "LOT_SIZE"}["stepSize"])
      ((amount / step_size).truncate * step_size).to_digits
    end
  end

  def position_by_ticker(ticker)
    @client.account_info["balances"].detect{ |position| position["asset"] == ticker.upcase}["free"]
  end

  
end