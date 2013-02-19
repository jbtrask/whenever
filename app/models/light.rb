class Light < ActiveRecord::Base
  attr_accessible :code, :label, :name, :hue_id
  has_and_belongs_to_many :people, :foreign_key => "light_code", :association_foreign_key => "person_code"
end
