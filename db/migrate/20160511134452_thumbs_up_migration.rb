class ThumbsUpMigration < ActiveRecord::Migration
  def self.up
    create_table :votes, :force => true do |t|

      t.boolean    :vote,     :default => false,    :null => false
      t.references :voteable, :polymorphic => true, :null => false
      t.references :voter,    :polymorphic => true
      t.timestamps

    end

    add_index :votes, [:voter_id, :voter_type]
    add_index :votes, [:voteable_id, :voteable_type]


  end

  def self.down
    drop_table :votes
  end

end