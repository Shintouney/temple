require 'pagy/extras/bootstrap'
require 'pagy/extras/navs'

Pagy::VARS[:steps] = { 0 => [2,3,3,2], 540 => [3,5,5,3], 720 => [5,7,7,5] }

Rails.application.config.assets.paths << Pagy.root.join('javascripts')