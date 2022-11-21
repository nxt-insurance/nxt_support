module NxtSupport
  module Middleware
    class SentryErrorID
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        if status >= 500 && env['sentry.error_event_id']
          headers["Sentry-Error-Id"] = env['sentry.error_event_id']
        end
        [status, headers, body]
      end
    end
  end
end
