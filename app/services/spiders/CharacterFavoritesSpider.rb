class Spiders::CharacterFavoritesSpider < Kimurai::Base
   
  @name = 'character_favorites_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url)
    @start_urls = [url]
    @config[:cookies] = [
      {
        name: "laravel_session", 
        value: YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))["account_cookie"], 
        domain: "toyhou.se"
      }
    ]
    
    favorites = self.parse!(:parse, url: @start_urls[0], data: {})
    return favorites
  end

  def parse(response, url:, data: {})
    character = {}

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths].include?(character[:owner][:name])
        puts "User is authorized"
      else
        return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
      end
    end
    
    character[:name] = response.css('li.character-name').text.strip
    character[:profile_img] = response.css('img.mr-2')[0]['src']

    character[:favorites] = []
    response.css("div.user-cell").each do |user_cell|
      user = {}
      user[:image] = user_cell.css("img.mw-100")[0]['src']
      user[:name] = user_cell.css("div.user-name").text.strip

      character[:favorites] << user
    end

    return character
  end
end