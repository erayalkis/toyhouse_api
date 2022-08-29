class Spiders::AuthorizationsSpider < Spiders::ToyhouseSpider
  @name = 'authorizations_spider'

  def parse(response, url:, data: {})
    auths = Set.new

    unless response.css("form.form-horizontal").empty?
      xsrf_token_input = response.xpath('//input[@name="_token"]/@value')[1].value

      data = {
        "_token": xsrf_token_input,
        "username": Rails.application.credentials.toyhouse_account[:username],
        "password": Rails.application.credentials.toyhouse_account[:password]
      }

      cookie_jar = HTTParty::CookieHash.new

      puts browser.driver.get_cookies
      session_cookie = browser.driver.get_cookies[0]
      xsrf_token_cookie = browser.driver.get_cookies[1]
      cookie_jar.add_cookies(session_cookie.to_s)
      cookie_jar.add_cookies(xsrf_token_cookie.to_s)

      headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': '100',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'sec-ch-ua': '"Opera GX";v="89", "Chromium";v="103", "_Not:A-Brand";v="24"',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.134 Safari/537.36 OPR/89.0.4447.104',
        'Cookie': cookie_jar.to_cookie_string
      }

      response = HTTParty.post('https://toyhou.se/~account/login', { body: URI.encode_www_form(data), headers: headers })

      new_cookie = response.headers['Set-Cookie']
      access_yaml = YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))
      access_yaml["account_cookie"] = new_cookie.split(", ")[2..4].join(", ").split("=")[1].split(";")[0]
      access_yaml["xsrf_cookie"] = xsrf_token_cookie

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