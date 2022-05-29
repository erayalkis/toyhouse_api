class UsersControllerSpec

  describe UsersController do 
    before(:all) do
      @user = {
        url: "https://toyhou.se/toyhouse_downloader",
        id: "toyhouse_downloader"
      }
    end

    describe "#profile" do
      it "should return a 500 error when an invalid ID string is passed in" do
        get :profile, :params => { id: "------" }
        assert_response :internal_server_error
      end

      it "should fetch data successfully" do
        get :profile, :params => { id: @user[:id] }
        assert_response :success
      end

      it "should fetch the correct data" do
        get :profile, :params => { id: @user[:id] }
        data = JSON.parse(response.body)
        expect(data["name"]).to eq("toyhouse_downloader")
      end

      it "should fetch all data correctly" do
        get :profile, :params => { id: @user[:id] }
        data = JSON.parse(response.body)

        expect(data["name"]).to eq("toyhouse_downloader")
        expect(data["recent_characters"][0]["name"]).to eq("test character!!!")
        expect(data["recent_characters"][0]["profile"]).to eq("/15895178.test-character-")
        expect(data["recent_characters"][0]["image"]).to eq("https://f2.toyhou.se/file/f2-toyhou-se/characters/15895178?1651272177")
        # Description might change, but a length higher than 0 means we're fetching the description
        expect(data["description"].length).to be > 0
      end

    end
  end
end