class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :code
      t.string :name
      t.string :label

      t.timestamps
    end
  end
end
