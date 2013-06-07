JBT_IPHONE = 'E4:25:E7:C0:52:BB'
PERIOD = 10 #seconds

i = 0
loop do
	i += 1
	ping_result = `sudo l2ping -c 1 #{JBT_IPHONE}`
	puts "#{i}:  #{DateTime.now}\n\n#{ping_result}\n\n"
	sleep PERIOD
end
