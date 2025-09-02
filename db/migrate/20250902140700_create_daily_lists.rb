class CreateDailyLists < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_lists do |t|
      t.date :date, null: false
      t.string :list_type, null: false
      t.integer :sequence_number, default: 1, null: false
      t.string :status, default: 'open', null: false
      t.integer :max_players, default: 5, null: false
      t.string :created_by, default: 'system'

      t.timestamps
    end
    
    # Índices para performance e integridade
    add_index :daily_lists, [:date, :list_type, :sequence_number], unique: true, name: 'idx_daily_lists_unique'
    add_index :daily_lists, [:date, :list_type, :status], name: 'idx_daily_lists_search'
  end
end
