class RequestControllerSpec

  describe RequestsController do

    describe "#scrape_character_profile" do
      before(:all) do     
        @character = {
          url: "https://toyhou.se/15895178.test-character-",
          id: "15895178.test-character-"
        }
      end

      it "should return a 404 Not Found error when an id isn't passed in" do
        get :scrape_character_profile
        assert_response :not_found
      end

          
      it "should fetch data successfully" do
        get :scrape_character_profile, :params => { id: @character[:id] }
        # Just updating the response instance variable so I don't make repeated requests
        # Don't wanna accidentally DOS the server yknow
        assert_response :success
      end

      it "should fetch the correct data" do
        get :scrape_character_profile, :params => { id: @character[:id] }
        data = JSON.parse(response.body)
        expect(data["name"]).to eq("test character!!!")
      end
    end


      

  end

end