require 'net/http'
require 'json'

class Weather
    include Cinch::Plugin

    match /weather (.+)/

    def weather(location)
        if config[:owm_key]
            uri = URI("http://api.openweathermap.org/data/2.5/weather?q=#{location}&units=metric&appid=#{config[:owm_key]}")
            page = Net::HTTP.get(uri)
            weather = JSON.parse(page)

            if weather != nil and weather["name"] != nil
                location = "#{weather["name"]}, #{weather["sys"]["country"]}"
                celsius = "#{weather["main"]["temp"]}°C"
                description = weather["weather"][0]["main"]
                humidity = "#{weather["main"]["humidity"]}%"
                wind_speed = "#{weather["wind"]["speed"]}km/h"

                return "[\x0311Weather\x03] #{location}, #{celsius}, #{description}, #{humidity}, #{wind_speed}"
            end
            return "[\x0311Weather\x03] Error."
        else
            return "[\x0311Weather\x03] No API key has been provided for this module."
        end
    end

    def execute(m, location)
        m.reply(weather(location))
    end
end
