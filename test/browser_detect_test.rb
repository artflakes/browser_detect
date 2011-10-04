require File.expand_path(File.dirname(__FILE__)+'/test_helper')
require File.dirname(__FILE__) + '/../lib/browser_detect'

class BrowserDetectTest < Test::Unit::TestCase
  fixtures :user_agents

  def mock_browser(ua=nil)
    BrowserDetectMock.new(ua)
  end

  must "deal with nil user agent gracefully" do
    assert_nothing_raised do
      mock_browser.browser_is?('something')
    end
  end

  must "identifies robot" do
    mock = mock_browser("Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
    assert mock.browser_is?('robot')
  end

  must "identify suggy bot" do
    mock = mock_browser("Mozilla/5.0 (compatible; suggybot v0.01a, http://blog.suggy.com/was-ist-suggy/suggy-webcrawler/)")
    assert mock.browser_is?('robot')
  end

  must "identifies robots" do
    mock = mock_browser("Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
    assert mock.browser_is?('robots')
  end

  must "not treat users as robots" do
    mock = mock_browser("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_7) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30")
    assert_equal false, mock.browser_is?('robot')
  end

  must "correctly mock a user agent string" do
    mock = mock_browser("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)")
    assert_equal("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)", mock.request.env['HTTP_USER_AGENT'])
  end

  must "identify googlebot" do
    mock = mock_browser("Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
    assert(mock.browser_is?('googlebot'))
  end

  must "identify Safari" do
    mock = mock_browser("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50")
    assert(mock.browser_is?('safari'))
  end

  must "not identify Chrome as Safari" do
    mock = mock_browser("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.122 Safari/534.30")
    assert_equal false, mock.browser_is?('safari')
  end

  must "correctly identify known user agents" do
    user_agents(:browsers).each do |browser|
      mock = mock_browser(browser['ua'])
      browser['name'].each do |name|
        assert(mock.browser_is?(name), "Browser '#{browser['nickname']}' did not match name '#{name}'!")
      end
    end
  end

  must "correctly identify webkit versions" do
    mock = mock_browser("Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_7; en-us) AppleWebKit/533.4 (KHTML, like Gecko) Version/4.1 Safari/533.4")
    assert(mock.browser_is?('webkit'))
    assert_equal(533.4, mock.browser_webkit_version)
  end
  
  must "correctly identify firefox versions 3.x" do
    mock = mock_browser("Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; de; rv:1.9.2.23) Gecko/20110920 Firefox/3.6.23")
    assert(mock.browser_is?('firefox'))
    assert_equal(3.6, mock.browser_firefox_version)
  end

  must "correctly identify firefox versions 7.x" do
    mock = mock_browser("Mozilla/5.0 (Windows NT 5.1; rv:7.0.1) Gecko/20100101 Firefox/7.0.1")
    assert(mock.browser_is?('firefox'))
    assert_equal(7.0, mock.browser_firefox_version)
  end


  must "handle strange user agent strings for iOS apps" do
    mock = mock_browser("Times/(null) (iPad; http://www.acrylicapps.com/pulp/)")
    assert(mock.browser_is?('ios'))
    assert(mock.browser_is?('webkit'))
    assert_equal(0, mock.browser_firefox_version)
  end
end

class BrowserDetectMock
  include BrowserDetect

  def initialize(user_agent=nil)
    @user_agent = user_agent
  end

  def request
    @req ||= mock_req
  end

  def mock_req
    req = Object.new
    metaclass = class << req; self; end
  user_agent = @user_agent
  metaclass.send :define_method, :env, Proc.new { {'HTTP_USER_AGENT' => user_agent} }
  req
end  
end
