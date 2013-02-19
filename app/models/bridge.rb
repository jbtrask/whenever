require "net/http"

class Bridge

  IP_ADDRESS = "192.168.0.12"
  USERNAME = "920164f914917985cd5e5489753a4329"

  def Bridge.info
    JSON.parse(Net::HTTP.get(URI.parse(self.base_url))) rescue nil
  end

  def Bridge.set_light(id, options)
    value = options
    value = Light::COLORS[value] if value.class == Symbol
    value = value.to_json if value.class == Hash
    http = Net::HTTP.new(Bridge::IP_ADDRESS)
    response = http.request_put("/api/#{Bridge::USERNAME}/lights/#{id}/state", value)
    "200" == response.code
  end

  def Bridge.all_off
    Light.all.each do |light|
      self.set_light(light.hue_id, on: false)
    end
  end

  private

  def Bridge.base_url
    "http://#{Bridge::IP_ADDRESS}/api/#{Bridge::USERNAME}"
  end

end