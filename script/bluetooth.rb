require 'bluetooth'

address = 'a4-c3-61-33-c9-01'
period = 10.0 #seconds

device = Bluetooth::Device.new address

loop do
  begin
    print 'initiating... '
    device.connect { puts "connected:  #{device.to_s}" }
  rescue Interrupt
    exit
  rescue Bluetooth::OfflineError
    abort 'you need to enable bluetooth'
  rescue Bluetooth::Error
    puts "#{$!} (#{$!.class})"
  ensure
    puts 'sleeping'
    sleep period
  end
end
