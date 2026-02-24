# Rate limiting and throttling configuration
# See https://github.com/rack/rack-attack for full documentation

class Rack::Attack
  # Throttle all requests by IP (60 requests per minute)
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle login attempts by IP address (5 attempts per 20 seconds)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/login" && req.post?
  end

  # Throttle login attempts by email parameter (5 attempts per minute)
  throttle("logins/email", limit: 5, period: 60.seconds) do |req|
    if req.path == "/login" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle password reset requests (5 per hour per email)
  throttle("password_resets/email", limit: 5, period: 1.hour) do |req|
    if req.path == "/password" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Block suspicious requests (SQL injection patterns, etc.)
  blocklist("block/bad-requests") do |req|
    Rack::Attack::Fail2Ban.filter("bad-requests:#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
        req.path.include?("/etc/passwd") ||
        req.path.include?("wp-admin") ||
        req.path.include?("wp-login")
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |_env|
    [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded. Retry later." }.to_json]]
  end
end
