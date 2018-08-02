require './lib/main'
require './lib/coin_market_cap'

main = Main.new
while true
  puts main.main_menu
  response = gets.chomp
  case response.downcase
  when "1"
    puts main.print_positions
  when "2"
    puts main.sell
  when "3"
    puts main.withdraw
  when 'q'
    break
  end  
end
