class Card < ActiveRecord::Base
  belongs_to :sprint
  attr_accessible :assignee, :description, :key, :points, :sprint_id, :status, :summary, :type
end
