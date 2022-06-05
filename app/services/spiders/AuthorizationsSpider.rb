class Spiders::AuthorizationsSpider < Spiders::ToyhouseSpider
  @name = 'authorizations_spider'

  def parse(response, url:, data: {})
    auths = Set.new

    unless response.css("form.form-horizontal").empty?
      data = [["login_username", Rails.application.credentials.toyhouse_account[:username]],
        ["login_password", Rails.application.credentials.toyhouse_account[:password]]]

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