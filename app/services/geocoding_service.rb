require 'net/http'
require 'json'

class GeocodingService
    class GeocodingError < StandardError; end

    API_KEY = Rails.application.credentials.dig(:google_maps, :api_key)
    BASE_URL = 'https://maps.googleapis.com/maps/api/geocode/json'.freeze

    def self.geocode(address)
        result = Rails.cache.fetch("address:#{address}", expires_in: 30.minutes) do
        begin
            uri = URI(BASE_URL)
            params = { address: address, key: API_KEY }
            uri.query = URI.encode_www_form(params)

            response = Net::HTTP.get(uri)
            json_data = JSON.parse(response)

            if json_data['status'] == 'OK'
                location = json_data['results'].first['geometry']['location']
                zip_code = json_data['results'].first[0].address_components[6].long_name;
                [location['lat'], location['lng'], zip_code]
            elsif json_data['status'] == 'ZERO_RESULTS'
                Rails.logger.warn("No results found for this address: #{address}")
                nil
            else
                Rails.logger.error("Google Geocoding API Error: #{json_data['status']}")
                raise GeocodingError, "The geocoding API returned an error: #{json_data['status']}"
            end

            rescue StandardError => e
                Rails.logger.error("An error occurred: #{e.message}")
                raise GeocodingError, "An error occurred."
            end
        end

        result
    end
end
