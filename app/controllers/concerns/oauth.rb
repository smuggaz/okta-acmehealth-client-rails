def call_introspect(issuer, token, config)
  # Calls /introspect endpoint to check if accessToken is valid

  url = "#{issuer}/oauth2/v1/introspect"
  header = build_header(config)
  data = { 'token' => token }

  # Send introspect request
  response = HTTParty.post(
  	url,
  	:query => data,
  	:headers => header
	)

  if response.code != 401
	  return JSON.parse response.body
  else
	  # Error
	  res = {
		  'Error Code' => response.code,
		  'Error Message' => response.message,
		  'Error Body' => response.body
	  }
	  return JSON.parse res.to_json
  end
end

def call_revocation(issuer, token, config)
  # Calls /revocation endpoint to revoke current accessToken

  url = "#{issuer}/oauth2/v1/revoke"
  header = build_header(config)
  data = { 'token' => token }

  # Send revoke request
  response = HTTParty.post(
  	url,
  	:query => data,
  	:headers => header
  )

  res = {}
  if response.code == 204
	# Success
	res = {
      'Success' => 'Token Revoked'
	}
  else
	# Error
	res = {
    'Error Code' => response.code,
	  'Error Message' => response.message,
	  'Error Body' => response.body
	}
  end

  return JSON.parse res.to_json
end

def build_header(config)
  require "base64"
  
  # Builds the header for sending requests
  authorization_header = Base64.strict_encode64("#{config['client_id']}:#{config['client_secret']}")
  header = {
	  'Authorization' => "Basic: #{authorization_header}".strip(),
	  'Content-Type' => 'application/x-www-form-urlencoded'
  }

  return header
end

