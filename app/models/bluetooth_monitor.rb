
class BluetoothMonitor

	require 'solareventcalculator'
	include ActionView::Helpers::DateHelper

	attr_accessor :last_on, :last_off, :last_seen, :options
	attr_reader :now

	DEFAULTS = {
		period: 15, #seconds
		away: 2, #minutes
		twilight: 15, #minutes
		date_format: {
			db: '%Y-%m-%dT%l:%M:%S%z',
			display: '%a,  %B %e, %l:%M %p'
		}
	}

	def initialize(options = {})
		self.options = options.reverse_merge DEFAULTS
	end

	def ping
    self.reset_now
		ping_result = `sudo l2ping -c 1 #{ENV['BLUETOOTH_MAC']}`
		action = 'none'
		if ping_result.match(/1 sent, 1 received/)
			status = 'present'
			self.last_seen = self.now
			if is_dark?
			  if self.last_on.blank? || (self.last_off.present? && self.last_off > self.last_on)
			    self.last_on = self.now
			    action = 'on'
			    Light.all_on
			  end
			end
  		else
		    status = 'missing'
		    if self.last_seen.blank? || self.now - self.last_seen > self.options[:away] * 60 #sec/min
		      if self.last_off.blank? || (self.last_on.present? && self.last_off < self.last_on)
		        self.last_off = self.now
		        action = 'off'
		        if is_dark?
              hue = (65535.0 * self.now.minute.to_f / 60.0).to_i
              Light.order(:hue_id).all.each {|l| l.on hue: hue, bri: 1 }
            else
              Light.all_off
            end
		      end
		    end
		end
		return status, action
	end

  def start_loop
    puts self.row(:header)
    i = 0
    loop do
      i += 1
      status, action = self.ping
      puts self.row(current_values(i, status, action))
      sleep self.options[:period]
    end
  end

  def start_cycle
    idx = 0
    loop do
      hue = (65535.0 * idx.to_f / 60.0).to_i
      Light.order(:hue_id).all.each {|l| l.on hue: hue, bri: 1}
      idx += 1
      idx = 0 if idx > 59
      sleep 1
    end
  end

  def is_dark?(dt = DateTime.now.in_time_zone)
		sunrise = SolarEventCalculator.new(dt.to_date, ENV['LATITUDE'].to_f, ENV['LONGITUDE'].to_f).compute_utc_official_sunrise
		sunset = SolarEventCalculator.new(dt.to_date + 1.day, ENV['LATITUDE'].to_f, ENV['LONGITUDE'].to_f).compute_utc_official_sunset
		dt < sunrise + self.options[:twilight].minutes || dt > sunset - self.options[:twilight].minutes
	end

	def reset_now
		@now = DateTime.now.in_time_zone
	end

	def row(values)
		values = :header == values ? self.header_values : values
		values.join(', ')
	end

	def header_values
		%w{
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
	end

	def current_values(iteration, status, action)
		[
			iteration,
			self.now.try{|t| t.strftime(self.options[:date_format][:display])} || 'no now',
			self.now.try{|t| t.strftime(self.options[:date_format][:db])} || '---',
			status,
			self.now.try{|t| is_dark?(t) ? 'dark' : 'light'} || 'no sun',
			action,
			self.last_seen.try{|t| time_ago_in_words(t, include_seconds: true)} || '--- ',
			self.last_seen.try{|t| t.strftime(self.options[:date_format][:db])} || 'never seen',
			self.last_on.try{|t| t.strftime(self.options[:date_format][:db])} || 'never on',
			self.last_off.try{|t| t.strftime(self.options[:date_format][:db])} || 'never off'
		]
  end

end
