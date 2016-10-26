class User < ActiveRecord::Base

	def self.find_or_create_by_auth(claims)
		user = find_or_create_by(email: claims["email"], uid: claims["sub"])
		if user.email != claims["email"]
			user.email = claims["sub"]
			user.save
		end
		return user
	end
end
