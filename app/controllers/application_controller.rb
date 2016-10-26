class ApplicationController < ActionController::Base
  require 'concerns/tokenmanager.rb'


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :get_discovery
end


def get_discovery
  # Get discovery document for provider
  response = HTTParty.get(Okta_Config['audience'] + '/.well-known/openid-configuration')
  doc_json = JSON.parse response.body
  @discovery_doc = doc_json

  # Init token_manager
  @token_manager = TokenManager.new()

end
