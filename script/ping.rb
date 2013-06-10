require 'action_view/helpers/date_helper'
require 'solareventcalculator'

PERIOD = 15 # seconds
AWAY_TIME = 2 # minutes
DATE_FORMAT = '%Y-%m-%d %l:%M:%S%p (%a)'

@on_time = @off_time = @last_seen_time = nil

def is_dark?
  now = DateTime.now
  solar_calculator = SolarEventCalculator.new(now.in_time_zone.to_date, ENV['LATITUDE'].to_f, ENV['LONGITUDE'].to_f)
  sunrise = solar_calculator.compute_utc_official_sunrise
  sunset = solar_calculator.compute_utc_official_sunset
  now < sunrise || now > sunset
end

def lights_off
  Light.all_off
end

def lights_on
  Light.all.each do |l|
    l.on bri: 254, hue: 13122, sat: 211 # ct: 467
  end
end

def time_ago(reference_time)
  if reference_time.present?
    "#{reference_time.strftime(DATE_FORMAT)} (#{time_ago_in_words(reference_time, include_seconds: true)})"
  else
    'NEVER'
  end
end

header = %w{
  idx
  time
  status
  action
  dark
  last
  on
  off
}
puts header.join(', ')

i = 0
loop do
	i += 1
  ping_result = `sudo l2ping -c 1 #{ENV['BLUETOOTH_MAC']}`
  action = 'NONE'
  if ping_result.match(/1 sent, 1 received/)
    status = 'PRESENT'
    @last_seen_time = Time.now
    if is_dark?
      if @on_time.blank? || (@off_time.present? && @off_time > @on_time)
        action = 'ON'
        @on_time = @last_seen_time
        lights_on
      end
    end
  else
    status = 'MISSING'
    if @last_seen_time.blank? || Time.now - @last_seen_time > AWAY_TIME * 60 #sec/min
      if @off_time.blank? || (@on_time.present? && @off_time < @on_time)
        action = "OFF"
        @off_time = Time.now
        lights_off
      end
    end
  end

  report = 
  [
    i,
    DateTime.now.in_time_zone.strftime(DATE_FORMAT),
    status,
    action,
    is_dark?,
    time_ago(@last_seen_time),
    time_ago(@on_time),
    time_ago(@off_time)
  ]
  puts report.join(', ')

  sleep PERIOD

end

