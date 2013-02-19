class Person < ActiveRecord::Base

  attr_accessible :code, :label, :name, :color
  has_and_belongs_to_many :lights, :foreign_key => "person_code", :association_foreign_key => "light_code"

  def self.seed(overwrite = false)

    path = Rails.root.join('db','seeds','people.yml')
    File.open(path) do |file|
      YAML.load_documents(file) do |doc|
        doc.keys.each do |key|
          attributes = doc[key].merge(code: key)
          light = attributes.delete("light")
          puts "ATTR: #{attributes.inspect}"
          attributes["color"] = Light::COLORS[attributes["color"].to_sym].to_json if attributes["color"].index("{").nil?
          record = find_or_create_by_code key, attributes
          record.update_attributes! attributes if overwrite
          record.lights << Light.find_by_code(light)
        end
      end
    end

  end

end

