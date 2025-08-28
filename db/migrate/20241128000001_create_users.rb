class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :nickname, null: false
      t.string :phone
      t.string :category, null: false
      t.json :positions, default: []
      t.string :preferred_position
      t.boolean :active, default: true
      
      t.timestamps
    end
    
    add_index :users, :nickname, unique: true
    add_index :users, :phone, unique: true
    add_index :users, :category
    add_index :users, :active
  end
end