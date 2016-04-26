class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.string :color1
      t.string :color2
      t.string :color3

      t.timestamps null: false
    end
  end
end
