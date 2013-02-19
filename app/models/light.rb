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

end
