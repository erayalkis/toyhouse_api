class Spiders::CharacterCommentsSpider < Spiders::ToyhouseSpider
  @name = 'character_comments_spider'

  def parse(response, url:, data: {})
    comments = []

    response.css("forum-post-post").each do |comment|
      curr = {}
      curr[:user] = {}
      curr[:user][:image] = comment.css("forum-post-avatar img")[0]['href']
      curr[:user][:username] = comment.css("forum-post-user-badge a").text
      curr[:body] = comment.css("user-content").text

      comments << curr
    end

    comments
  end
end