# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "images")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w( OktaAuth.min.js )
Rails.application.config.assets.precompile += %w( OktaAuth.min.js.map )
Rails.application.config.assets.precompile += %w( okta-sign-in.min.js )
Rails.application.config.assets.precompile += %w( master.js )
Okta_Config = YAML.load_file(Rails.root.join('config/config.yml'))[Rails.env]
