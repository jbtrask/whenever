class AddColorToPeople < ActiveRecord::Migration
  def change
    add_column :people, :color, :string
  end
end
