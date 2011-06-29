module BrowserDetect
  # Define browser groupings (mobile, robots, etc.)
  # Also define complex queries like IE where we weed out user agents that pose as IE
  # The default case just checks if the user agent contains the query string
  def browser_is? query
    query = query.to_s.strip.downcase
    result = case query
             when /^ie(\d+)$/
               includes?("msie #{$1}") and not includes?('opera') and not includes?('webtv')
             when 'ie'
               includes?(/msie \d/) and not includes?('opera') and not includes?('webtv')
             when 'mozilla'
               includes?('gecko') || includes?('mozilla')
             when 'webkit'
               includes?(/webkit|safari|chrome|iphone|ipad|ipod/)
             when 'ios'
               includes?(/iphone|ipad|ipod/)
             when /^robot(s?)$/
               includes?(/googlebot|msnbot|yahoo! slurp|baidu/)
             when 'mobile'
               browser_is?('ios') || includes?(/android|webos|mobile/)
             else
               includes?(query)
             end
    result
  end

  # Determine the version of webkit.
  # Useful for determing rendering capabilities
  # For instance, Mobile Webkit versions lower than 532 don't handle webfonts very well (intermittent crashing when using multiple faces/weights)
  def browser_webkit_version
    if browser_is? 'webkit'
      match = ua.match(%r{\bapplewebkit/([\d\.]+)\b})
      match[1].to_f if (match)
    end or 0
  end

  # Gather the user agent and store it for use.
  def ua
    @ua ||= begin
              request.env['HTTP_USER_AGENT'].downcase
            rescue
              ''
            end
  end

  def includes? needle
    not ua.match(needle).nil?
  end
end
