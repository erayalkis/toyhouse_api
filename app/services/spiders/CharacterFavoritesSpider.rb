class Spiders::CharacterFavoritesSpider < Spiders::ToyhouseSpider
  @name = 'character_favorites_spider'

  def parse(response, url:, data: {})
    character = {}

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths]&.include?(character[:owner][:name])
        puts "User is authorized"
      else
        return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
      end
    end
    
    character[:name] = response.css('li.character-name').text.strip
    character[:owner] = {}
    character[:owner][:name] = response.css("span.display-user-username")[1].text
    character[:owner][:link] = response.css("span.display-user a")[0]['href']
    character[:profile_img] = response.css('img.mr-2')[0]['src']

    character[:favorites] = []
    response.css("div.user-cell").each do |user_cell|
      user = {}
      user[:image] = user_cell.css("img.mw-100")[0]['src']
      user[:username] = user_cell.css("div.user-name").text.strip

      character[:favorites] << user
    end

    return character
  end
end