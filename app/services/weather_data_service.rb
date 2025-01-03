require 'net/http'
require 'json'

class WeatherDataService
  class WeatherDataError < StandardError; end

  API_KEY = Rails.application.credentials.dig(:open_weather_map, :api_key)
  BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'.freeze

  def self.get_weather(coordinates)
    result = Rails.cache.fetch("weather_data:#{coordinates}", expires_in: 30.minutes) do
      begin
        uri = URI(BASE_URL)
        params = { lat: "#{coordinates[0]}", lon: "#{coordinates[1]}", appid: API_KEY, units: 'imperial' }
        uri.query = URI.encode_www_form(params)

        response = Net::HTTP.get(uri)
        json_response = JSON.parse(response)

        if json_response['cod'] == 200
          json_response
        elsif json_response['cod'] == '404'
          Rails.logger.warn("Weather data not found.")
          nil
        else
          Rails.logger.error("OpenWeatherMap API Error: #{json_response['message']}")
          raise WeatherDataError, "OpenWeatherMap API returned an error: #{json_response['message']}"
        end

      rescue SocketError => e
        Rails.logger.error("Network error during weather retrieval: #{e.message}")
        raise WeatherDataError, "A network error occurred during weather retrieval."
      rescue JSON::ParserError => e
        Rails.logger.error("Error parsing OpenWeatherMap API response: #{e.message}")
        raise WeatherDataError, "Could not parse the OpenWeatherMap API response."
      rescue StandardError => e
        Rails.logger.error("An unexpected error occurred during weather retrieval: #{e.message}")
        raise WeatherDataError, "An unexpected error occurred during weather retrieval. #{e.message}"
      end
    end

    result
  end
end