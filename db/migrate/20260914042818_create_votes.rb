class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :color, null: false, foreign_key: true
      t.string :voter_key, null: false

      t.timestamps
    end

    # Enforces one vote per visitor per color at the database level.
    add_index :votes, [ :color_id, :voter_key ], unique: true
  end
end
