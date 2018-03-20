module Social
    class Twitter
        include Cinch::Plugin

        def self.setup_needed
            true
        end
        
        def self.apis
            ["twitter"]
        end

        match %r{http(?:s)?:\/\/(?:www.)?twitter.com\/([^ ?/]+)(?:\/status\/(\d+))?}, use_prefix: false, method: :twitter_url
        match /twitter @?(\w{1,15})/, method: :twitter_user
        match /lt @?(\w{1,15})/, method: :last_tweet

        def twitter_url(m, user_name, status_id)
            if status_id != nil
                status = bot.apis["twitter"].status(status_id)

                text = status.text.gsub("\n", " ")

                m.reply("[\x0311Twitter\x03] \"#{text}\" by #{status.user.name} (@#{status.user.screen_name}) from #{status.created_at.strftime("%F %R")} - RTs: #{status.retweet_count} - Favourites: #{status.favorite_count}")
            elsif user_name != nil
                user = bot.apis["twitter"].user(user_name.downcase)

                if user.location.count > 0
                    location = " - Location: #{user.location}"
                else
                    location = ""
                end
                if user.description.count > 0
                    description = " - \"#{user.description.gsub(/\R+/, ' ')}\""
                else
                    description = ""
                end
                m.reply("[\x0311Twitter\x03] #{user.name} (@#{user.screen_name})#{location}#{description} - Following: #{user.friends_count} - Followers: #{user.followers_count}")
            end
        end

        def twitter_user(m, query)
            user = bot.apis["twitter"].user(query.downcase)

            if user != nil
                if user.location.count > 0
                    location = " - Location: #{user.location}"
                else
                    location = ""
                end
                if user.description.count > 0
                    description = " - \"#{user.description.gsub(/\R+/, ' ')}\""
                else
                    description = ""
                end
                m.reply("[\x0311Twitter\x03] #{user.name} (@#{user.screen_name})#{location}#{description} - Following: #{user.friends_count} - Followers: #{user.followers_count} - https://twitter.com/#{query}")
            end
        end

        def last_tweet(m, query)
            status = bot.apis["twitter"].user_timeline(query.downcase, count: 1).first

            text = status.text.gsub("\n", " ")

            m.reply("[\x0311Twitter\x03] \"#{text}\" by #{status.user.name} (@#{status.user.screen_name}) from #{status.created_at.strftime("%F %R")} - RTs: #{status.retweet_count} - Favourites: #{status.favorite_count}")
        end
    end
end