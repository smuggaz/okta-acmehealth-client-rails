class TokenManager
  def initalize()
	  @idToken = nil
	  @accessToken = nil
    @claims = nil
  end
  
  def idToken=(token)
    @idToken = token
  end

  def accessToken=(token)
    @accessToken = token
  end

  def claims=(c)
    @claims = c
  end
end