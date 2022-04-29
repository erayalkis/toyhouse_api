class RequestControllerSpec
  
  describe "Character Scraper" do

    before(:all) do
      @character = {
        url: "https://toyhou.se/15895178.test-character-",
        id: "15895178.test-character-"
      }
      @controller = RequestsController.new
    end

    it "should not fetch data when an id isn't passed in" do
      get :scrape_character_profile
      assert_response :not_found
    end

    it "should fetch data successfully" do
      get :scrape_character_profile, :params => { id: @character[:id] }

      assert_response :success
    end

  end

end