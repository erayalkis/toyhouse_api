class Spiders::AuthorizationsSpider < Kimurai::Base

  @name = 'authorizations_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url)
    @start_urls = [url]
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

    auths = self.parse!(:parse, url: @start_urls[0])
    return auths
  end

  def parse(response, url:, data: {})
    auths = Set.new

    unless response.css("form.form-horizontal").empty?
      browser.fill_in "login_username", match: :first, with: "toyhouse_downloader"
      browser.fill_in "login_password", match: :first, with: Rails.application.credentials.account_password
      browser.click_button "Sign in", match: :first
      response = browser.current_response
      new_cookie = browser.driver.get_cookies[0]

      access_yaml = YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))
      access_yaml["account_cookie"] = new_cookie.value

      File.open(Rails.root.join('config', 'access_cookie.yml'), 'w+') { |f| YAML.dump(access_yaml, f) }

      return Spiders::AuthorizationsSpider.instance("https://toyhou.se/~account/authorizers")
    end

    if response.css('div.row.align-items-end').empty?
      return Set.new
    end

    # unless response.css('i.fa.fa-unlock-alt').empty?
    #   return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
    # end

    usernames = response.css("a.btn.btn-sm.user-name-badge")
    usernames.each do |username|
      auths.add username.text
    end

    return auths
  end
end