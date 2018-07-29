require './lib/binance_wrapper'

class Main
  def initialize
    @cmc = CoinMarketCap.new
  end

  def connect_binance
    # puts "connect to Binance API: "
    @binance = BinanceWrapper.new
  end

  def main_menu
    str = "Main Menu\n"
    str += "1.  List positions\n"
    str += "2.  Sell\n"
    str += "Q.  Quit\n"
    str += "-----------\n"
    str += "What would you like to do?"
    str
  end

  def positions(min_val=2)
    @binance || connect_binance
    str = "--- Positions ---\n"
    str = "symbol  |  size  =>  USD value\n"
    balances = @binance.balances.select{ |position| position['mkt_val'].to_d > min_val }
    balances = balances.sort{ |a, b| b['mkt_val'].to_d <=> a['mkt_val'].to_d }
    balances.each do |p|
      str += position_line_item p
    end
    str += "----- end of positions -----\n"
    str
  end

  def position_line_item(position)
    ticker = position['asset']
    # "#{ticker}  #{position['free']} @ #{@cmc.quote(ticker)}\n"
    "#{ticker}  #{position['free']}   =>  #{position['mkt_val'].to_f.round(2)}\n"
  end

  def sell
    @binance || connect_binance
    puts "enter ticker to sell ('BNB' or 'ADA BCC SALT')"
    ticker = gets.chomp.upcase
    puts "enter base currency 'ETH' or 'BTC'"
    base = gets.chomp.upcase

    pair = ticker + base
    size = BigDecimal.new(@binance.position_by_ticker(ticker.upcase))
    order_size = @binance.order_size(pair, size).to_s

    puts "sell #{ticker} for #{base}"
    puts "full size: #{size}"
    puts "order size: #{order_size}"
  end
end


# tickers = %w[IOTA ETC ZEN BCC]
# base = 'ETH'
# tickers.each do |ticker|
#   pair = ticker.upcase + base.upcase
#   size = BigDecimal.new(binance.position_by_ticker(ticker.upcase))
#   order_size = binance.order_size(pair, size).to_s
#   puts "selling #{ticker}"
#   puts "full size: #{binance.position_by_ticker(ticker)}"
#   puts "order size: #{order_size}"
#   opts = {
#     symbol: pair,
#     quantity: order_size
#   }
#   p binance.sell(opts)
# end