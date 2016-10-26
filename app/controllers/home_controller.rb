class HomeController < ApplicationController
	require_relative 'concerns/tokens.rb'
	require_relative 'concerns/openid.rb'
	require_relative 'concerns/oauth.rb'
		
  def getContext(layout)
    context = {
      :layout => layout
    }

    if session.key?('tokens')
      context[:tokens] = session[:tokens]
      tokens_hash = JSON session[:tokens]
      if tokens_hash.key?('claims')
        context[:claims] = JSON.pretty_generate(tokens_hash["claims"])
      end
    end

		@layout = context[:layout]
    @tokens = JSON context[:tokens]
    @claims = context[:claims]
	end

	def index
		getContext('page-Schedule has-sidebar')
    if !session[:user_id]
      redirect_to "/login"
    end
	end

	def callback
		# Handles the token exchange from the sign-in widget

		def token_request(code, nonce)
	  	# Setup the token request
	  	  
      token_endpoint = @discovery_doc["token_endpoint"]
	  	
      tokens = call_token_endpoint(token_endpoint, code, Okta_Config)
      claims = nil
	  	  
      if tokens.empty? == false
	  	  if tokens.key?('id_token') == true
	  	  	# Perform token validation
          claims = token_validation(tokens["id_token"], Okta_Config, nonce)

          # Store token and claims
          @token_manager.idToken = tokens["id_token"]
          @token_manager.claims = claims
	  	  end

	  	  if tokens.key?('access_token') == true 
          @token_manager.accessToken = tokens["access_token"]
	  	  end
  	  end

  	  return claims, @token_manager.to_json
  	end

  	code = request.GET["code"]
  	state = request.GET["state"]

    # Get state and nonce from cookie
    cookie_state = cookies[:"okta-oauth-state"]
    cookie_nonce = cookies[:"okta-oauth-nonce"]

    # Verify state matches
    if state != cookie_state
      puts "Value #{state} does not match the assigned state"
      redirect_to "/login"
    end
      
    nonce = cookie_nonce
  	user, token_manager_json = token_request(code, nonce)

    if user
      # Create / authenticate user
      new_or_existing_user = User.find_or_create_by_auth(user)
      session[:user_id] = new_or_existing_user.id
      puts "USER: #{user}"
      session[:tokens] = token_manager_json
      redirect_to action: "index"
    end

    if !user
      redirect_to "/login"
    end
  	
  end

  def logout
    reset_session
    @token_manager = nil
    redirect_to "/login"
  end
end




