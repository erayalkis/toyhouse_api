class Spiders::CharacterDetailsSpider < Spiders::ToyhouseSpider
  @name = 'character_details_spider'

  def parse(response, url:, data: {})
    character = {}
    character[:owner] = {}
    character[:owner][:name] = response.css('span.display-user > a > span.display-user-username').text

    if response.css('div.col-sm-12.content-main > div.character-profile').empty?
      return nil
    end

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths]&.include?(character[:owner][:name])
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