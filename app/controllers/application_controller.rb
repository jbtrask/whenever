class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_bridge

  def set_bridge
    @bridge = Bridge.new
  end

end
