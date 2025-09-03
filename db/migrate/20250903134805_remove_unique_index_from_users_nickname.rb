class RemoveUniqueIndexFromUsersNickname < ActiveRecord::Migration[7.1]
  def change
    # Remove unique index from nickname (allows duplicate nicknames)
    remove_index :users, :nickname if index_exists?(:users, :nickname)
    
    # Add composite unique index for name + phone combination
    add_index :users, [:name, :phone], unique: true, name: 'index_users_on_name_and_phone'
  end
end
