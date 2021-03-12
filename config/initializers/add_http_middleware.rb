if Rails.env.production? || Rails.env.staging?
  require "#{Rails.root}/lib/rack/http_headers_rewriter"
  Temple::Application.config.middleware.insert_after(Rack::Sendfile, Rack::HttpHeadersRewriter)
end