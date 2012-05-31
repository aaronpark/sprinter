module ApplicationHelper
  def auth
    auth = {:username => ENV['SPRINTER_USERNAME'], :password => ENV['SPRINTER_PASSWORD']}
  end
end
