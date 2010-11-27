class DirectMessage < ActiveRecord::Base
  belongs_to :sender, :class_name => User.name
  belongs_to :recipient, :class_name => User.name
  
  validates :content, :presence => true
  validates :sender, :presence => true
  validates :recipient, :presence => true
end
