class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table :recipients do |t|
      t.integer :micropost_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :recipients
  end
end
