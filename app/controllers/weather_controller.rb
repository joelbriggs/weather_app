class WeatherController < ApplicationController
    before_action :set_location, only: [:index]

    def index
      if params[:address].present? # Check if an address has been submitted
        address = params[:address]

        begin
            coordinates = get_coordinates_from_address(address)
            if coordinates
                @weather_data = get_weather_data_from_coordinates(coordinates)
                if @weather_data
                    @location = load_location_from_zip_code(coordinates)
                else
                    flash.now[:alert] = "Could not retrieve weather data for that location."
                end
            else
            flash.now[:alert] = "Invalid address. Please enter a valid address."
            end
        rescue GeocodingService::GeocodingError => e
            Rails.logger.error("Geocoding error: #{e.message}")
            flash.now[:alert] = "An error occurred while geocoding. Please try again later."
        rescue WeatherDataService::WeatherDataError => e
            Rails.logger.error("Weather API error: #{e.message}")
            flash.now[:alert] = "An error occurred while retrieving weather data. Please try again later."
        end
        end
    end
  
    def create
        redirect_to weather_index_path(address: params[:location][:address])
    end

    private

    def set_location
        @location = Location.new
    end

    def get_coordinates_from_address(address)
        GeocodingService.geocode(address)
    end

    def get_weather_data_from_coordinates(coordinates)
        WeatherDataService.get_weather(coordinates)
    end

    def load_location_from_zip_code(coordinates)
        Location.find_or_create_by(zip_code: coordinates[2]) do |location|
            location.latitude = coordinates[0]
            location.longitude = coordinates[1]
        end
    end
  end