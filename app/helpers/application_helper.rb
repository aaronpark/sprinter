module ApplicationHelper
  def auth
    auth = {:username => ENV['SPRINTER_USERNAME'], :password => ENV['SPRINTER_PASSWORD']}
  end
  

  
  def work_days_between(date1, date2)
    work_days = 0
    date1.upto(date2) do |day|
      work_days = work_days + 1 unless day.saturday? || day.sunday?
    end
    work_days
  end
  
end
