# -*- coding: binary -*-

module Msf::HTTP::Wordpress::Login
  # performs a wordpress login
  #
  # @param user [String] Username
  # @param pass [String] Password
  # @param timeout [Integer] The maximum number of seconds to wait before the request times out
  # @return [String,nil] the session cookies as a single string on successful login, nil otherwise
  def wordpress_login(user, pass, timeout = 20)
    redirect = "#{target_uri}#{Rex::Text.rand_text_alpha(8)}"
    res = send_request_cgi({
        'method' => 'POST',
        'uri' => wordpress_url_login,
        'vars_post' => wordpress_helper_login_post_data(user, pass, redirect)
    }, timeout)
    if res && res.redirect? && res.redirection && res.redirection.to_s == redirect
      cookies = res.get_cookies
      # Check if a valid wordpress cookie is returned
      return cookies if
        # current Wordpress
        cookies =~ /wordpress(?:_sec)?_logged_in_[^=]+=[^;]+;/i ||
        # Wordpress 2.0
        cookies =~ /wordpress(?:user|pass)_[^=]+=[^;]+;/i ||
        # Wordpress 2.5
        cookies =~ /wordpress_[a-z0-9]+=[^;]+;/i
    end

    nil
  end
end