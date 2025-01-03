require "test_helper"
require 'minitest/mock'

class WeatherControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    get weather_index_url
    assert_response :success
  end

  test "should redirect to index with address param on create" do
    post weather_index_url, params: { location: { address: "1 Apple Park Way Cupertino California 95014" } }
    assert_redirected_to weather_index_url(address: "1 Apple Park Way Cupertino California 95014")
  end

  # test "should get weather data with valid address" do
  #   get weather_index_url, params: { location: { address: "1 Apple Park Way Cupertino California 95014" } }
    
  #   assert_response :success
  # end

  test "should get weather data with valid address" do
    address = "1 Apple Park Way Cupertino California 95014"
    coordinates = [37.3291382, -122.008638, '95014']
    weather_data =  {"address"=>"1 Apple Park Way Cupertino California 95014"}
    {"coord"=>{"lon"=>-122.0086, "lat"=>37.3291},
     "weather"=>[{"id"=>801, "main"=>"Clouds", "description"=>"few clouds", "icon"=>"02n"}],
     "base"=>"stations",
     "main"=>
      {"temp"=>53.29,
       "feels_like"=>52.18,
       "temp_min"=>51.06,
       "temp_max"=>56.43,
       "pressure"=>1017,
       "humidity"=>82,
       "sea_level"=>1017,
       "grnd_level"=>991},
     "visibility"=>10000,
     "wind"=>{"speed"=>3.44, "deg"=>180},
     "clouds"=>{"all"=>20},
     "dt"=>1735890334,
     "sys"=>{"type"=>2, "id"=>2005590, "country"=>"US", "sunrise"=>1735831342, "sunset"=>1735866109},
     "timezone"=>-28800,
     "id"=>5341145,
     "name"=>"Cupertino",
     "cod"=>200}

    Rails.cache.stub(:fetch, address) do
      WeatherDataService.stub(:get_weather, weather_data) do
        get weather_index_url, params: { address: address }
        assert_response :success
        assert_not_nil assigns(:weather_data)
        assert_equal weather_data, assigns(:weather_data)
        assert_not_nil assigns(:location)
      end
    end
  end
end
