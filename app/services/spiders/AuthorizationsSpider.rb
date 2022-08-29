class Spiders::AuthorizationsSpider < Spiders::ToyhouseSpider
  @name = 'authorizations_spider'

  def parse(response, url:, data: {})
    auths = Set.new

    unless response.css("form.form-horizontal").empty?
      xsrf_token_input = response.xpath('//input[@name="_token"]/@value')[1].value

      data = [
        ["username", Rails.application.credentials.toyhouse_account[:username]],
        ["password", Rails.application.credentials.toyhouse_account[:password]],
        ["_token", xsrf_token_input]
      ]
      xsrf_token_cookie = browser.driver.get_cookies[1].to_s.split("=")[1]
      headers = {
        'XSRF-TOKEN' => xsrf_token_cookie,
        'Content-Type' => 'application/x-www-form-urlencoded'
      }

      uri = URI('https://toyhou.se/~account/login')
      response = Net::HTTP.post(uri, URI.encode_www_form(data), headers)

      new_cookie = response['Set-Cookie']
      xsrf_token_cookie = response['XSRF-TOKEN']

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