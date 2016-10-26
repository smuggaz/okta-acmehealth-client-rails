class LoginController < ApplicationController
  def index
    @config = {
      :url => Okta_Config['audience'],
      :clientId => Okta_Config['client_id'],
      :redirectUri => Okta_Config['redirect_uri'],
      :scope => Okta_Config['scope'],
      :idp => Okta_Config['idp']
    }
    @layout = 'page-Login'
  end
	
end