JBT_IPHONE = 'E4:25:E7:C0:52:BB'
PERIOD = 10 #seconds
AWAY_TIME = 60 #seconds
SUNSET_TIME = '7:45PM'

%w{present on off}.each do |type|
  filename = "tmp/last_#{type}.log"
  puts filename
  File.open(filename, 'w+') do |f|
    f.write(Time.now.to_s)
  end unless File.exists?("tmp/last_#{type}.log")
end

i = 0
loop do
	i += 1
	ping_result = `sudo l2ping -c 1 #{JBT_IPHONE}`
	puts "#{i}:  #{Time.now.to_s}\n\n#{ping_result}\n\n"
  present_timestamp = Time.parse(File.read('tmp/last_present.log'))
  off_timestamp = Time.parse(File.read('tmp/last_off.log'))
  on_timestamp = Time.parse(File.read('tmp/last_on.log'))
  if ping_result.match(/1 sent, 1 received/)
    puts "PRESENT (since #{on_timestamp.to_s})\n\n"
    File.open('tmp/last_present.log', 'w+') do |f|
      f.write(Time.now.to_s)
    end
    sunset_time = Time.parse("#{Date.today.to_s} #{SUNSET_TIME}")
    puts "sunset:  #{sunset_time.to_s}"
    if Time.now > sunset_time && on_timestamp <= sunset_time
      puts "ON\n\n"
      File.open('tmp/last_on.log', 'w+') do |f|
        f.write(Time.now.to_s)
      end
      Light.each do |l|
        l.on bri: 255, hue: 255
      end
    end
  elsif Time.now - present_timestamp > AWAY_TIME
    if off_timestamp <= present_timestamp
      puts "OFF\n\n"
      File.open('tmp/last_off.log', 'w+') do |f|
        f.write(Time.now.to_s)
      end
      Light.all_off
    end
  else
    puts "RECENTLY MISSING\n\n"
  end
	sleep PERIOD
end

