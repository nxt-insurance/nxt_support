module NxtSupport
  module Middleware
    class SentryErrorID
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        if status >= 500 && env['sentry.error_event_id']
          headers['Sentry-Error-Id'] = env['sentry.error_event_id']
          exposed_headers = headers['Access-Control-Expose-Headers'] || headers['access-control-expose-headers']
          headers['Access-Control-Expose-Headers'] = [exposed_headers, 'Sentry-Error-Id'].compact.join(', ')
        end
        [status, headers, body]
      end
    end
  end
end
