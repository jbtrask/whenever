class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_bridge

  def set_bridge
    session[:bridge] = @bridge = session[:bridge] || Bridge.new
    @bridge.refresh_info if params.has_key?(:refresh)
  end

end
