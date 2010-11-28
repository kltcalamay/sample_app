class AddFollowerNotificationsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :follower_notifications, :boolean, :default => true
  end

  def self.down
    remove_column :users, :follower_notifications
  end
end
