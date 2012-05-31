class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include ActionView::Helpers::TextHelper
end
