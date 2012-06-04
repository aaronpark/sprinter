class Sprint < ActiveRecord::Base
  include ApplicationHelper
  has_many :cards
  attr_accessible :end_date, :name, :start_date, :xid

  def business_days_between(date1, date2)
    business_days = 0
    date = date2
    while date >= date1
     business_days = business_days + 1 unless date.saturday? or date.sunday?
     date = date - 1.day
    end
    business_days
  end
  
  def velocity
    self.cards.sum('points')
  end
  
  def type_count(type)
    self.cards.where("card_type = '#{type}'").count
  end
  
end
