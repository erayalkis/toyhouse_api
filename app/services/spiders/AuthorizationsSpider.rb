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
      data = [["login_username", "toyhouse_downloader"],
        ["login_password", Rails.credentials.account_cookie]]

      uri = URI('https://toyhou.se/~account/login')
      response = Net::HTTP.post_form(uri, data)

      new_cookie = response['Set-Cookie']
 
      access_yaml = YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))
      access_yaml["account_cookie"] = new_cookie.split(";")[5].split(",")[1].split("=")[1].strip

      File.open(Rails.root.join('config', 'access_cookie.yml'), 'w+') { |f| YAML.dump(access_yaml, f) }

      return Spiders::AuthorizationsSpider.instance("https://toyhou.se/~account/authorizers")
    end

    if response.css('div.row.align-items-end').empty?
      return Set.new
    end

    usernames = response.css("a.btn.btn-sm.user-name-badge")
    usernames.each do |username|
      auths.add username.text
    end

    return auths
  end
end