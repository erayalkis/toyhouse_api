class Spiders::CharacterGallerySpider < Spiders::ToyhouseSpider
  @name = 'character_gallery_spider'

  def parse(response, url:, data: {})
    character = {}
    character[:owner] = {}
    character[:owner][:name] = response.css('span.display-user > a > span.display-user-username').text

    if response.css('ul.magnific-gallery').empty?
      return { msg: 'Character has no images or character profile is locked!', status: 422 }
    end

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths]&.include?(character[:owner][:name])
        puts "User is authorized"
      else
        return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
      end
    end
    
    character[:owner][:link] = response.css('span.display-user > a')[0]['href']
    character[:name] = response.css('li.character-name').text.strip
    character[:gallery] = []

    response.css('li.gallery-item').each_with_index do |item, idx| 
      name = item.css('div.artist-credit').text.strip
      a = item.css('div.thumb-image > a')[0]
      
      character[:gallery] << { link: a['href'], artist: { name: name, profile: get_profile_name(name)} }
    end
    return character
  end

  private

  def get_profile_name(name) # Artist profile link can either be a simple name string, or a link for an external website
    if name.starts_with?("https") || name.starts_with?("http")
      return name
    else
      return "https://toyhou.se/#{name}"
    end
  end
end