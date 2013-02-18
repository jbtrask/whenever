class AddHueIdToLights < ActiveRecord::Migration
  def change
    add_column :lights, :hue_id, :string
  end
end
