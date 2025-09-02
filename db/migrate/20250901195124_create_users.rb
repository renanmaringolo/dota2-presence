class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :nickname, null: false
      t.string :name, null: false
      t.string :phone
      t.string :rank_medal, null: false
      t.integer :rank_stars, null: false
      t.string :preferred_position
      t.text :positions, default: '[]' # JSON array as text
      t.string :category, null: false
      t.string :role, default: 'player'
      t.boolean :active, default: true
      t.string :password_digest, null: false

      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :nickname, unique: true
    add_index :users, :phone, unique: true
    add_index :users, :role
    add_index :users, :category
  end
end
