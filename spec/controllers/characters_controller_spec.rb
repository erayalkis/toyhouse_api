require "kimurai"
require "rails_helper"

class CharactersControllerSpec

  describe CharactersController do

    before(:all) do      
      @character = {
        url: "https://toyhou.se/15895178.test-character-",
        id: "15895178.test-character-"
      }

      @authorized_character = {
        url: "https://toyhou.se/10868863.-yui-",
        id: "10868863.-yui-"
      }

      # Disable logging for kimurai when running tests
      Kimurai.configure do |config|
        config.logger = Logger.new(nil)
      end
    end

    describe "#profile" do

      it "should return a Not Found error when an ID string isn't passed in" do
        get :profile, :params => { id: @character[:id] }
        assert_response :not_found
      end

      it "should make a fetch call successfully" do 
        get :profile, :params => { id: @character[:id] }
        assert_response :success
      end

      it "should fetch the correct data" do
        get :profile, :params => { id: @character[:id] }
        data = JSON.parse(response.body)
        expect(data["name"]).to eq("test character!!!")
      end

      it "should fetch all data corectly" do
        get :profile, :params => { id: @character[:id] }
        data = JSON.parse(response.body)

        expect(data["name"]).to eq("test character!!!")
        expect(data["creator"]["name"]).to eq("toyhouse_downloader")
        expect(data["creator"]["profile"]).to eq("https://toyhou.se/toyhouse_downloader")
        expect(data["owner"]["name"]).to eq("toyhouse_downloader")
        expect(data["owner"]["profile"]).to eq("https://toyhou.se/toyhouse_downloader")
        expect(data["description"]).to eq("here!!!!\n")
        # Value might change, but will always be more than 0
        expect(data["fav_count"].to_i).to be > 0 
      end

      it "should fetch data from authorized characters" do
        get :profile, :params => { id: @authorized_character[:id] }
        assert_response :success
      end

      it "should fetch the correct data from authorized characters" do
        get :profile, :params => { id: @authorized_character[:id] }
        data = JSON.parse(response.body)
        expect(data["name"]).to eq(" 🌊 yui !! 🌊")
      end

      it "should fetch all data correctly from authorized characters" do
        get :profile, :params => { id: @authorized_character[:id] }
        data = JSON.parse(response.body)

        expect(data["name"]).to eq(" 🌊 yui !! 🌊")
        expect(data["creator"]["name"]).to eq("SPARKNIGHT")
        expect(data["creatore"]["profile"]).to eq("https://toyhou.se/SPARKNIGHT")
        expect(data["owner"]["name"]).to eq("kyumi")
        expect(data["owner"]["profile"]).to eq("https://toyhou.se/kyumi")
        # Description might change, but a length higher than 0 means we're fetching the description
        expect(data["description"].length).to be > 0
        # Value might change, but will always be more than 0
        expect(data["fav_count"]).to be > 0
      end

    end
    
  end

end