class AuthorizationsSpider < Kimurai::Base
   
  @name = 'authorizations_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    cookies: [{name: "laravel_session", value: "eyJpdiI6IkZpY2REUjg5bmpKQ1BCZE1sWVp4VEE9PSIsInZhbHVlIjoiUVk5V0tIRDFvcWpyVVROQm1MU2ZwTDRYcXNldW5xcEw1RFNKRzF6RGlPbzc4V0Y5cXc0bE1qZGdvMUpITDFRa0MyaVJhOFh4ZkVnbVF4MVowbzdCTEZveURxaXdlZk5CK09oVHNTZU1KUXMrSVA4VERwUVV0QW8yWkcyZU5RdUQiLCJtYWMiOiIyMGVkMmYxNTNhNTY3NjBkMGMzMjU1MGQ5ZWZlYjBjYjJkNjQyMjFhMTc0OGM4Y2ViMmYwYmQ4NWMzMzk0NTBlIn0%3D", domain: "toyhou.se"}]
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

    auth_container = response.css("div.row.align-items-end")
    auth_container.each do |auth_block|
      auths.add response.css("a.btn.btn-sm.user-name-badge").text
    end

    return auths
  end
end