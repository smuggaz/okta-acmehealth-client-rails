def token_validation(token, config, nonce)
  # Perform token validation

  def jwks(kid, url)
	# Return JWKS Keys with public key format
	response = HTTParty.get(url)
	jwks = JSON.parse response.body
	
	return JSON::JWK::Set.new jwks
  end

  begin
	# Step 1
	# If encrypted, decrypt it using the keys and algorithms specified in the meta_data
	# If encryption was negotiated but not provided, REJECT
		
	decoded_token = JWT.decode token, nil, false
	
	dirty_claims = decoded_token[0]
	dirty_headers = decoded_token[1]
	dirty_alg = dirty_headers["alg"]
	dirty_kid = dirty_headers["kid"]

	# Get discovery document
	response = HTTParty.get("#{dirty_claims['iss']}/.well-known/openid-configuration")
	discovery = JSON.parse response.body
	dirty_keys = jwks(dirty_kid, discovery["jwks_uri"])
 		
	# Validate Key using JSON-JWT
	begin
      JSON::JWT.decode token, dirty_keys
 	rescue Exception => e
 	  puts e.message
 	end 

 	if discovery['issuer'] != dirty_claims['iss']
	  # Step 2
	  # Issuer Identifier for the OpenID Provider (which is typically
	  # obtained during Discovery) MUST exactly match the value of the iss (issuer) Claim.
	  raise 'Discovery document Issuer does not match client_id'
	end

	if dirty_claims['iss'] != config["audience"]
	  # Step 3
	  # Client MUST validate:
	  # aud (audience) contains the same `client_id` registered
	  # iss (issuer) identified as the aud (audience)
	  # aud (audience) Claim MAY contain an array with more than one element (Not implemented by Okta)
	  # The ID Token MUST be rejected if the ID Token does not list the Client as a valid
	  # audience, or if it contains additional audiences not trusted by the Client.
	  raise 'Issuer does not match client_id'
	end

	if dirty_claims["aud"].kind_of?(String) == true
	  # Single element
	  if dirty_claims["aud"] != config["client_id"]
		raise 'Audience does not match client_id'
	  end
	end

	if dirty_claims["aud"].kind_of?(Array) == true
	  exists = dirty_claims["aud"].include? config["client_id"] ? true : false
	  if exists == false
		raise 'No Issuers match client_id'
	  else
	    if dirty_claims.key?("azp") == true
		  # Step 4
		  # If ID Token contains multiple audiences, verify that an azp claim is present
		  if dirty_claims["azp"] != config["client_id"]
	        # Step 5
		    # If azp (authorized part), verify client_id matches
		    raise 'azp value does not match client_id'
		  end
	    else
		  raise 'azp value not provided'
	    end
	  end
    end
	
	# Step 6
	# TLS server validation not implemented by Okta
	# If ID Token is received via direct communication between Client and Token Endpoint,
	# TLS server validation may be used to validate the issuer in place of checking token
	# signature. MUST validate according to JWS algorithm specialized in JWT alg Header.
	# MUST use keys provided.

	if discovery["id_token_signing_alg_values_supported"].include? dirty_alg == false
	  # Step 7
	  # The alg value SHOULD default to RS256 or sent in id_token_signed_response_alg param during Registration
	  raise 'alg provided in token does not match id_token_signing_alg_values_supported'
	end

	# Step 8
	# Not implemented due to Okta configuration
	# If JWT alg Header uses MAC based algorithm (HS256, HS384, etc) the octets of UTF-8 of the
	# client_secret corresponding to the client_id are contained in the aud (audience) are
	# used to validate the signature. For MAC based, if aud is multi-valued or if azp value
	# is different than aud value - behavior is unspecified.
	
	if dirty_claims['exp'].to_i < Time.now.to_i
	  # Step 9
	  # The current time MUST be before the time represented by exp
	  raise 'exp provided has expired'
	end

	if dirty_claims['iat'].to_i < (Time.now.to_i - 10000)
	  # Step 10
	  # Defined 'too far away time' : approx 24hrs
	  # The iat can be used to reject tokens that were issued too far away from current time,
	  # limiting the time that nonces need to be stored to prevent attacks. 
	  raise 'iat too far in the past ( > 1 day)'
	end

	if nonce
	  # Step 11
	  # If a nonce value is sent in the Authentication Request, a nonce MUST be present and be
	  # the same value as the one sent in the Authentication Request. Client SHOULD check for nonce value
	  # to prevent replay attacks.
	  if nonce != dirty_claims['nonce']
		raise 'nonce value does not match Authentication Request nonce'
	  end
	end

	# Step 12
	# Not implemented by Okta
	# If acr was requested, check that the asserted Claim Value is appropriate

	if dirty_claims.key?('auth_time') == true
      # Step 13
	  # If auth_time was requested, check claim value and request re-authentication if too much time elapsed
	  if dirty_claims['auth_time'].to_i < (Time.now.to_i - 10000)
		raise 'auth_time too far in past ( > 1 day)'
	  end
	end

	# Return token
	return dirty_claims

  rescue Exception => e
    puts e.message
  end
  
end
