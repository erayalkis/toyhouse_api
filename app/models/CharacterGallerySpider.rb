class galleryGallerySpider < Kimurai::Base
   
  @name = 'character_gallery_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url)
    @start_urls = [url]


    gallery = self.parse!(:parse, url: @start_urls[0])
    return gallery
  end

  def parse(response, url:, data: {})
    gallery = []
    
    return gallery
  end
end