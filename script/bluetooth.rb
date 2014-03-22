require 'bluetooth'

address = ENV['BLUETOOTH_MAC'].downcase.gsub(':', '-')

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
    sleep ENV['BLUETOOTH_PERIOD']
  end
end
