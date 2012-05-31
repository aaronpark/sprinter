class Sprint < ActiveRecord::Base
  has_many :cards
  attr_accessible :end_date, :name, :start_date, :xid
end
