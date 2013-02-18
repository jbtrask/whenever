class Person < ActiveRecord::Base
  attr_accessible :code, :label, :name
  has_and_belongs_to_many :lights, :foreign_key => "person_code", :association_foreign_key => "light_code"
end
