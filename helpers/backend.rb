module Helpers
    module Backend
        def get_priv(username, api_key)
            if api_key
                uri = URI("#{Helpers.get_config["settings"]["syndbb_url"]}/api/irc/?nick=#{username}&get_profile=1&api=#{api_key}")
                page = Net::HTTP.get(uri)
                xml = Nokogiri::XML.parse(page)
                rank_number = xml.xpath('api/entry/rank').text.to_i
                
                ranks = {
                    900 => "a",
                    500 => "o",
                    100 => "h",
                    50 => "v",
                    0 => "v"
                }
                
                if rank_number != nil
                    return ranks[rank_number]
                else
                    return false
                end
            else
                return false
            end
        end

        def set_priv(m, flag, api_key)
            priv = get_priv(m.user, api_key)
            
            if priv != false
                m.bot.irc.send("MODE #{m.channel} #{flag}#{priv} #{m.user.nick}")
            else
                debug "User does not exist in the backend or the API key has not been provided."
            end
        end
        
        module_function :get_priv, :set_priv
    end
end
