class Spiders::CharacterCommentsSpider < Spiders::ToyhouseSpider
  @name = 'character_comments_spider'

  def parse(response, url:, data: {})
    pagination_wrapper = response.css("div.pagination-wrapper")
    comments = request_to :parse_comments_page, url: url

    if data[:comments]
      puts "adding new comments"
      data[:comments] += comments
    else
      puts "creating new subs array"
      data[:comments] = comments
    end

    next_page_wrapper = pagination_wrapper.empty? ? nil : pagination_wrapper.css("li.page-item")[-1]
    next_page = next_page_wrapper.nil? ? nil : next_page_wrapper.css(".page-link")[0]['href']

    if pagination_wrapper.length.zero? || next_page.nil?
      character = {}
      character[:name] = response.css("h1.comments-title a").text.strip
      character[:owner] = {}
      character[:owner][:name] = response.css("span.display-user-username")[1].text
      character[:owner][:link] = response.css("span.display-user a")[0]['href']
      character[:comments] = data[:comments]
      return character
    end

    request_to :parse, url: next_page, data: data.merge(comments: data[:comments])
  end

  def parse_comments_page(response, url, data: {})
    comments = []
    response.css("div.forum-post-post").each do |comment|
      curr = {}
      curr[:user] = {}

      # Disabled accounts won't have any data and will throw an error when being accessed
      image = comment.css("div.hidden-xs-down.forum-post-avatar > img")
      curr[:user][:image] = image.length > 0 ? image[0]['src'] : nil

      curr[:user][:username] = comment.css("span.forum-post-user-badge a").text.strip
      curr[:body] = comment.css("div.user-content").text.strip

      comments << curr
    end

    comments
  end
end