class CreateWhatsappMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :whatsapp_messages do |t|
      t.string :phone, null: false
      t.text :content, null: false
      t.string :status, default: 'pending'
      t.references :user, null: true, foreign_key: true
      t.references :presence, null: true, foreign_key: true
      t.text :error_message
      t.datetime :received_at
      
      t.timestamps
    end
    
    add_index :whatsapp_messages, :status
    add_index :whatsapp_messages, :phone
    add_index :whatsapp_messages, :received_at
  end
end