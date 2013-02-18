class CreateLights < ActiveRecord::Migration
  def change
    create_table :lights do |t|
      t.string :code
      t.string :name
      t.string :label

      t.timestamps
    end
  end
end
