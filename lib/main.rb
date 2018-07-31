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
    str += "3.  Buy Bitcoin\n"
    str += "Q.  Quit\n"
    str += "-----------\n"
    str += "What would you like to do?"
    str
  end


  def sell
    @binance || connect_binance
    
    print_top_positions(6)

    log = {}

    puts "enter ticker to sell ('BNB' or 'ADA BCC SALT')"
    tickers = gets.chomp.upcase.split(' ')

    while true
      puts "sell for ETH? (y/n)"
      response = gets.chomp.downcase
      if response == 'y'
        base = 'ETH'
        break
      else
        puts "sell for BTC? (y/n)"
        response = gets.chomp.downcase
        if response == 'y'
          base = 'BTC'
          break
        end
      end
    end
    tickers.each do |ticker|
      puts "ticker: #{ticker}"
      pair = ticker + base
      pair = "ETHBTC" if ticker == "BTC"
      if ticker == "BTC"
        size = how_much_eth_to_buy
      else
        size = BigDecimal.new(@binance.position_by_ticker(ticker.upcase))
      end
      
      order_size = @binance.order_size(pair, size).to_s
      order_opts = {
        symbol: pair,
        side: ticker == 'BTC' ? "BUY" : "SELL",
        type: "MARKET",
        quantity: order_size
      }
      log[ticker] = {
        "order" => order_opts,
        "response" => @binance.sell(order_opts)
      }
    end
    log
  end

  def top_positions(qty=5)
    @binance || connect_binance
    balances = @binance.balances.select{ |position| position['mkt_val'].to_d }
    balances = balances.sort{ |a, b| b['mkt_val'].to_d <=> a['mkt_val'].to_d }
    balances[0...qty]
  end

  def print_top_positions(num=5)
    puts "-- Top #{num} Holdings --"
    puts "symbol - qty - USD val"
    top_positions.each do |position|
      puts "#{position['asset']} #{position['free'].to_f.round(4)} $#{position['mkt_val'].to_f.round(2)}"
    end
    puts "--- --- --- ---"
  end

  def how_much_eth_to_buy
    pair = 'ETHBTC'
    btc_amount = @binance.position_by_ticker('BTC').to_d
    price = @binance.order_book(pair)["askPrice"].to_d
    btc_amount / price
  end

  def print_positions(min_val=2)
    @binance || connect_binance
    str = "--- Positions ---\n"
    str += "symbol  |  size  =>  USD value\n"
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
    "#{ticker}  #{position['free']}   =>  #{position['mkt_val'].to_f.round(2)}\n"
  end
end