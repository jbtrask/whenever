class CreateTableLightsPeople < ActiveRecord::Migration
  def change
    create_table :lights_people do |t|
      t.string :light_code
      t.string :person_code
    end
  end
end
