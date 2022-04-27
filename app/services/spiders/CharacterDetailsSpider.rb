class Spiders::CharacterDetailsSpider < Kimurai::Base
   
  @name = 'character_details_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url, auths)
    @start_urls = [url]
    @auths = auths
    @config["cookies"] = [
      {
        name: "laravel_session", 
        value: YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))["account_cookie"], 
        domain: "toyhou.se"
      }
    ]
    
    details = self.parse!(:parse, url: @start_urls[0], data: {auths: @auths})
    return details
  end

  def parse(response, url:, data: {})
    character = {}
    character[:owner] = {}
    character[:owner][:name] = response.css('span.display-user > a > span.display-user-username').text

    if response.css('div.col-sm-12.content-main > div.character-profile').empty?
      return nil
    end

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths].include?(character[:owner][:name])
        puts "User is authorized"
      else
        return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
      end
    end
    
    character[:name] = response.css('h1.display-4').text.strip
    character[:profile_img] = response.css('img.profile-name-icon')[0]["src"]
    return character
  end
end