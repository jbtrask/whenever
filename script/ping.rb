include ActionView::Helpers::DateHelper

JBT_IPHONE = 'E4:25:E7:C0:52:BB'
PERIOD = 15 # seconds
AWAY_TIME = 2 # minutes
SUNRISE_TIME = '5:40:AM' # 6/7/13
SUNSET_TIME = '7:54PM' # 6/7/13
DATE_FORMAT = '%Y-%m-%d %l:%M:%S%p (%a)'

@on_time = @off_time = @last_seen_time = nil

def is_dark?
  today = DateTime.now.in_time_zone.to_date
  sunrise_time = Time.zone.parse("#{today} #{SUNRISE_TIME}")
  sunset_time = Time.zone.parse("#{today} #{SUNSET_TIME}")
  Time.now < sunrise_time || Time.now > sunset_time
end

def lights_off
  Light.all_off
end

def lights_on
  Light.all.each do |l|
    l.on bri: 255, hue: 255
  end
end

def now
  DateTime.now.in_time_zone.strftime(DATE_FORMAT)
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
  ping_result = `sudo l2ping -c 1 #{JBT_IPHONE}`
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
    now,
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

