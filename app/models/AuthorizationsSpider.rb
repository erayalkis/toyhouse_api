class AuthorizationsSpider < Kimurai::Base
   
  @name = 'authorizations_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    cookies: [{name: "laravel_session", value: Rails.application.credentials.account_cookie, domain: "toyhou.se"}]
  }

  def self.instance(url)
    @start_urls = [url]


    auths = self.parse!(:parse, url: @start_urls[0])
    return auths
  end

  def parse(response, url:, data: {})
    auths = Set.new

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