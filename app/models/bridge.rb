require "net/http"

class Bridge

  IP_ADDRESS = "192.168.0.12"
  USERNAME = "920164f914917985cd5e5489753a4329"

  attr_accessor :info

  def initialize
    self.refresh_info
  end

  def refresh_info
    self.info = JSON.parse(Net::HTTP.get(URI.parse(self.get_base_url))) rescue nil
    puts info.to_yaml if info.present?
    self.info
  end

  def set_light(options)
    # make api call with options
  end

  def all_off
    # sequence to turn off all lights immediately
  end

  private

  def get_base_url
    "http://#{IP_ADDRESS}/api/#{USERNAME}"
  end

end