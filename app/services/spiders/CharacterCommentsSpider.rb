class Spiders::CharacterCommentsSpider < Spiders::ToyhouseSpider
  @name = 'character_comments_spider'

  def parse(response, url:, data: {})
    character = {}
    character[:name] = response.css("h1.comments-title a").text.strip
    character[:comments] = []

    response.css("div.forum-post-post").each do |comment|
      curr = {}
      curr[:user] = {}

      # Disabled accounts won't have any data and will throw an error when being accessed
      image = comment.css("div.hidden-xs-down.forum-post-avatar > img")
      curr[:user][:image] = image.length > 0 ? image[0]['src'] : nil
      
      curr[:user][:username] = comment.css("span.forum-post-user-badge a").text.strip
      curr[:body] = comment.css("div.user-content").text.strip

      character[:comments] << curr
    end

    character
  end
end