# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = Time.now.to_i.to_s

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( account.css account.js admin.css admin.js errors.css pdf.css card_print.css vendor/assets/javascript/bootstrap-confirmation.min.js vendor/assets/javascript/jquery.ui.touch-punch.min.js vendor/assets/javascript/jquery.lazy.min.js )
Rails.application.config.assets.paths << Rails.root.join("app/assets/fonts/*")
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

# In Rails 4, there is no way to by default compile both digest and non-digest assets.
# This is a pain in the arse for almost everyone developing a Rails 4 app. 
# This gem solves the problem with the minimum possible effort.
NonStupidDigestAssets.whitelist = [/.*\.html/]