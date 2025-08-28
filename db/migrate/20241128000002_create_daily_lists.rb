class CreateDailyLists < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_lists do |t|
      t.date :date, null: false
      t.string :status, default: 'generated'
      t.text :content
      t.json :summary, default: {}
      
      t.timestamps
    end
    
    add_index :daily_lists, :date, unique: true
    add_index :daily_lists, :status
  end
end