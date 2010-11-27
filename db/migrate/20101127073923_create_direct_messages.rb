class CreateDirectMessages < ActiveRecord::Migration
  def self.up
    create_table :direct_messages do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string :content

      t.timestamps
    end

    add_index :direct_messages, :sender_id
    add_index :direct_messages, :recipient_id
  end

  def self.down
    drop_table :direct_messages
  end
end
