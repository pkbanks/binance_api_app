require './lib/main'
require './lib/coin_market_cap'

main = Main.new
while true
  puts main.main_menu
  response = gets.chomp
  case response.downcase
  when "1"
    puts main.positions
  when "2"
    main.sell
  when 'q'
    break
  end  
end
