class AddUserIdToColors < ActiveRecord::Migration
  def change
    add_column :colors, :user_id, :integer
    add_index :colors, :user_id
  end
end
