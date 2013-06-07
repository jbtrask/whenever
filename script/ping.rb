JBT_IPHONE = 'E4:25:E7:C0:52:BB'
PERIOD = 10 #seconds

i = 0
loop do
	i += 1
	ping_result = `sudo l2ping -c 1 #{JBT_IPHONE}`
	puts "#{i}:  #{DateTime.now.to_s}\n\n#{ping_result}\n\n"
  if ping_result.match(/1 sent, 1 received/)
    puts "PRESENT\n\n"
    File.open('tmp/last.log', 'w+') do |f|
      f.write(DateTime.now.to_s)
    end
  end
	sleep PERIOD
end
