class Light < ActiveRecord::Base

  COLORS = {
    red: {hue: 65225, bri: 254},
    blue: {hue: 47103, bri: 254},
    magenta: {hue: 53056, bri: 254},
    purple: {hue: 44994, bri: 254},
    green: {hue: 26239, bri: 254},
    yellow: {hue: 23005, bri: 254},
    orange: {hue: 7745, bri: 254}
  }

  attr_accessible :code, :label, :name, :hue_id
  has_and_belongs_to_many :people, :foreign_key => "light_code", :association_foreign_key => "person_code"

  def on(options = {})
    Bridge.set_light(self.hue_id, options.merge("on" => true))
  end

  def off(options = {})
    Bridge.set_light(self.hue_id, options.merge("on" => false, transitiontime: 0))
  end

  def Light.cycle(options = {})
    options = options.reverse_merge(step: 2000, offset: 0, period: 0.1, transition: 1)
    base_hue = 0
    while true
      Light.order(:hue_id).all.each_with_index do |light, idx|
        hue = (base_hue + idx * options[:offset]) % 65535
        light.on({hue: hue, sat: 254, bri: 254, transitiontime: options[:transition]})
        sleep options[:period]
        light.on({hue: hue, sat: 254, bri: 1, transitiontime: options[:transition] / 2})
      end
      base_hue = (base_hue + options[:step]) % 65535
    end
  end

  def burst(options = {})
    options = options.reverse_merge fade: 1.0, hue: 0
    self.on transitiontime: 0, hue: options[:hue].to_i, sat: 254, bri: 254
    self.on transitiontime: (options[:fade].to_f * 10.0).to_i, hue: options[:hue].to_i, sat: 0, bri: 0
    sleep options[:fade].to_f
  end

  def Light.burst_all(options = {})
    options = options.reverse_merge fade: 1.0, hue: 0
    Light.order(:hue_id).all.each do |light|
      light.on transitiontime: 0, hue: options[:hue].to_i, sat: 254, bri: 254
      light.on transitiontime: (options[:fade].to_f * 10.0).to_i, hue: options[:hue].to_i, sat: 0, bri: 0
    end
    sleep options[:fade].to_f
    Light.order(:hue_id).all.each { |light| light.off }
  end

  def Light.all_off(burst = true)
    lights = Light.order(:hue_id).all
    if burst
      delay = 0.75 #seconds
      lights.each do |light|
        light.on hue: 0, sat: 0, bri: 254, transitiontime: 0
        light.on hue: 0, sat: 0, bri: 0, transitiontime: (delay * 10.0).to_i
      end
      sleep delay
    end
    lights.each {|light| light.off}
  end

  def Light.check_effect(options = {})
    Light.all_off
    sleep 0.2
    Light.first.on options.merge transitiontime: 2
  end

  def Light.seed(overwrite = false)

    path = Rails.root.join('db','seeds','lights.yml')
    File.open(path) do |file|
      YAML.load_documents(file) do |doc|
        doc.keys.each do |key|
          attributes = doc[key].merge code: key
          record = find_or_create_by_code key, attributes
          record.update_attributes! attributes if overwrite
        end
      end
    end

  end

end
