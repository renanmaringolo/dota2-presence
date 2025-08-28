class CreatePresences < ActiveRecord::Migration[7.1]
  def change
    create_table :presences do |t|
      t.references :user, null: false, foreign_key: true
      t.references :daily_list, null: false, foreign_key: true
      t.string :position, null: false
      t.string :source, default: 'web'
      t.datetime :confirmed_at
      t.string :status, default: 'confirmed'
      t.text :notes
      
      t.timestamps
    end
    
    # Ensure one user per daily list
    add_index :presences, [:daily_list_id, :user_id], unique: true
    # Ensure one position per daily list
    add_index :presences, [:daily_list_id, :position], unique: true
    add_index :presences, :source
    add_index :presences, :status
  end
end