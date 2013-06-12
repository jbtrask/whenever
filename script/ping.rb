require 'solareventcalculator'

include ActionView::Helpers::DateHelper

PERIOD = 15 # seconds
AWAY = 2 # minutes
TWILIGHT = 15 #minutes
DATE_FORMAT = {
  db: '%Y-%m-%dT%l:%M:%S%z',
  display: '%a,  %B %e, %l:%M %p'
}

@on = @off = @last_seen = nil

def is_dark?
  sunrise = SolarEventCalculator.new(@now.to_date, ENV['LATITUDE'].to_f, ENV['LONGITUDE'].to_f).compute_utc_official_sunrise
  sunset = SolarEventCalculator.new(@now.to_date + 1.day, ENV['LATITUDE'].to_f, ENV['LONGITUDE'].to_f).compute_utc_official_sunset
  @now < sunrise + TWILIGHT.minutes || @now > sunset - TWILIGHT.minutes
end

header = %w{
  idx
  time
  db_time
  status
  dark
  action
  ago
  last
  on
  off
}
puts header.join(', ')

i = 0
loop do

  i += 1
  @now = DateTime.now.in_time_zone

  ping_result = `sudo l2ping -c 1 #{ENV['BLUETOOTH_MAC']}`

  action = 'none'
  if ping_result.match(/1 sent, 1 received/)
    status = 'present'
    @last_seen = @now
    if is_dark?
      if @on.blank? || (@off.present? && @off > @on)
        @on = @now
        action = 'on'
        Light.all_on
      end
    end
  else
    status = 'missing'
    if @last_seen.blank? || @now - @last_seen > AWAY * 60 #sec/min
      if @off.blank? || (@on.present? && @off < @on)
        @off = @now
        action = 'off'
        Light.all_off
      end
    end
  end

  report = 
  [
    i,
    @now.strftime(DATE_FORMAT[:display]),
    @now.strftime(DATE_FORMAT[:db]),
    status,
    is_dark? ? 'dark' : 'light',
    action,
    @last_seen.try{|t| time_ago_in_words(t, include_seconds: true)} || '--- ',
    @last_seen.try{|t| t.strftime(DATE_FORMAT[:db])} || 'never seen',
    @on.try{|t| t.strftime(DATE_FORMAT[:db])} || 'never on',
    @off.try{|t| t.strftime(DATE_FORMAT[:db])} || 'never off'
  ]
  puts report.join(', ')

  sleep PERIOD

end

