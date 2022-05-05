class Spiders::CharacterGallerySpider < Kimurai::Base
   
  @name = 'character_gallery_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url, auths)
    @start_urls = [url]
    @auths = auths
    @config[:cookies] = [
      {
        name: "laravel_session", 
        value: YAML.load_file(Rails.root.join('config', 'access_cookie.yml'))['account_cookie'],
        domain: "toyhou.se"
      }
    ]

    puts "--------- AUTHS: #{@auths} ---------"
    gallery = self.parse!(:parse, url: @start_urls[0], data: {auths: @auths})
    return gallery
  end

  def parse(response, url:, data: {})
    character = {}
    character[:owner] = {}
    character[:owner][:name] = response.css('span.display-user > a > span.display-user-username').text
    artists = response.css('div.artist-credit')

    if response.css('ul.magnific-gallery').empty?
      return { msg: 'Character has no images or character profile is locked!', status: 422 }
    end

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths].include?(character[:owner][:name])
        puts "User is authorized"
      else
        return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
      end
    end
    
    character[:owner][:link] = response.css('span.display-user > a')[0]['href']
    character[:name] = response.css('li.character-name').text.strip
    character[:gallery] = []
    response.css('div.thumb-image > a').each_with_index do |a, i| 
      name = artists[i].text.strip
      character[:gallery] << { link: a['href'], artist: { name: name , profile: "https://toyhou.se/#{name}"} }
    end
    return character
  end
end