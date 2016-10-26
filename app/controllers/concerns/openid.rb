def call_token_endpoint(url, code, config)
  require "base64"
  # Call /token endpoint
  # Returns accessToken, idToken, or both
  authorization_header = Base64.strict_encode64("#{config['client_id']}:#{config['client_secret']}")
  header = {
	'Authorization' => "Basic: #{authorization_header}".strip(),
	'Content-Type' => 'application/x-www-form-urlencoded'
  }

  query = {
	'grant_type' => config['grant_type'],
	'code' => code,
	'scope' => config['scope'],
	'redirect_uri' => config['redirect_uri']
  }


  response = HTTParty.post(
	url,
	:query => query,
	:headers => header
  )
	
  response_json = JSON.parse response.body

  # Return object
  result = {}
  
  if response_json.key?("error") == false
  	if response_json.key?("access_token") == true 
  	  result['access_token'] = response_json["access_token"]
  	end

  	if response_json.key?("id_token") == true 
  	  result["id_token"] = response_json["id_token"]
  	end

  end

  return result
end

def call_userinfo_endpoint(url, token)
  # Call /userinfo endpoint
  header = {
  	"Authorization" => "Bearer #{token}"
  }
  response = HTTParty.get(url, :headers => header)
  
  if response.code != 401
    return JSON.parse response.body
  else
	res = {
      'Error Code' => response.code,
	  'Error Message' => response.message,
	  'Error Body' => response.body
	}
	return JSON.parse res.to_json
  end
end