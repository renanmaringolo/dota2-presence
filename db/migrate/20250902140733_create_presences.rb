class CreatePresences < ActiveRecord::Migration[7.1]
  def change
    create_table :presences do |t|
      t.references :user, null: false, foreign_key: true
      t.references :daily_list, null: false, foreign_key: true
      t.string :position, null: false
      t.string :source, default: 'web', null: false
      t.string :status, default: 'confirmed', null: false
      t.datetime :confirmed_at, null: false
      t.text :notes

      t.timestamps
    end
    
    # Constraints únicos críticos
    add_index :presences, [:daily_list_id, :position], unique: true, 
              where: "status = 'confirmed'", name: 'idx_presences_unique_position'
    add_index :presences, [:daily_list_id, :user_id], unique: true, 
              where: "status = 'confirmed'", name: 'idx_presences_unique_user'
    
    # Índices para performance
    add_index :presences, [:user_id, :status], name: 'idx_presences_user_status'
    add_index :presences, [:daily_list_id, :status], name: 'idx_presences_list_status'
  end
end
