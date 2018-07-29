require 'httparty'
require 'json'

class CoinMarketCap
  def initialize
    url = 'https://api.coinmarketcap.com/v2/ticker/'
    @data = JSON.parse(HTTParty.get(url).body)["data"].values

    url2 = 'https://api.coinmarketcap.com/v2/ticker/?start=101'
    @data += JSON.parse(HTTParty.get(url2).body)["data"].values

    listings_endpoint = 'https://api.coinmarketcap.com/v2/listings/'
    @listings = JSON.parse(HTTParty.get(listings_endpoint).body)["data"]
  end

  def listing(ticker)
    @listings.detect{ |listing| listing["symbol"] == ticker }
  end

  def quote(ticker)
    @data.detect { |curr| curr["symbol"] == ticker.upcase }
  end

end