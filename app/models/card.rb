class Card < ActiveRecord::Base
  belongs_to :sprint
  attr_accessible :assignee, :description, :key, :points, :sprint_id, :status, :summary, :type
  
  def card_status
    
    if self.status == 'Open' || self.status == 'Reopened'
      'To Do'
    elsif self.status == 'In Progress'
      'In Progress'
    elsif self.status == 'In Review'
      'In Review'
    elsif self.status == 'In QA'
      'In QA'
    elsif self.status == 'Closed'
      'Done'
    end

  end
end
