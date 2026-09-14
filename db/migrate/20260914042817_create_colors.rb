class CreateColors < ActiveRecord::Migration[8.1]
  def change
    create_table :colors do |t|
      t.string  :color1
      t.string  :color2
      t.string  :color3
      t.integer :votes_count, default: 0, null: false

      t.timestamps
    end
  end
end
