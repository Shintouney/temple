module Rack
  class HttpHeadersRewriter
    def initialize(app, _options = {})
      @app = app
    end

    def call(env)
      if env['HTTP_HTTP_X_FORWARDED_PROTO'] == 'https'
        env['HTTPS'] = 'on'
        env['HTTP_X_FORWARDED_PROTO'] = 'https'
      end
      @app.call(env)
    end
  end
end
