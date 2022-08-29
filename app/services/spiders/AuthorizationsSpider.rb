class Spiders::AuthorizationsSpider < Spiders::ToyhouseSpider
  @name = 'authorizations_spider'

  def parse(response, url:, data: {})
    auths = Set.new

    unless response.css("form.form-horizontal").empty?
      xsrf_token_input = response.xpath('//input[@name="_token"]/@value')[1].value
      cookie_jar = HTTParty::CookieHash.new

      data = {
        "username": Rails.application.credentials.toyhouse_account[:username],
        "password": Rails.application.credentials.toyhouse_account[:password],
        "_token": xsrf_token_input
      }

      xsrf_token_cookie = browser.driver.get_cookies[1]
      cookie_jar.add_cookies(xsrf_token_cookie.to_s)

      headers = {
        'XSRF-TOKEN' => cookie_jar.to_cookie_string,
        'Content-Type' => 'application/x-www-form-urlencoded'
      }

      response = HTTParty.post('https://toyhou.se/~account/login', { body: URI.encode_www_form(data), headers: headers  } )

      new_cookie = response.headers['Set-Cookie']

      access_yaml = YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))
      access_yaml["account_cookie"] = new_cookie.split(";")[0].split("=")[1]

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