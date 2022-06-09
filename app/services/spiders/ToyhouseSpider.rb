class Spiders::ToyhouseSpider < Kimurai::Base
  @engine = :mechanize

  def self.instance(url, auths=nil)
    @start_urls = [url]
    @config = {
      user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
      cookies: []
    }

    unless File.exists?(Rails.root.join('config', 'access_cookie.yml'))
      yaml = {'account_cookie' => nil}
      File.open(Rails.root.join('config', 'access_cookie.yml'), 'w+') { |f| YAML.dump(yaml, f) }
    end

    @config[:cookies] = [
      {
        name: "laravel_session", 
        value: YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))['account_cookie'],
        domain: "toyhou.se"
      }
    ]

    scraper_thread = Thread.new do
      self.parse!(:parse, url: @start_urls[0], data: { auths: @auths })
    end

    data = scraper_thread.value
    return data
  end

end