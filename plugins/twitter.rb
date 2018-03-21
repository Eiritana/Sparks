require 'twitter'

module URL
    class TwitterAPI
        include Cinch::Plugin

        def self.required_config
            ["keys:twitter_key", "keys:twitter_secret"]
        end

        def self.regex
            %r{http(?:s)?:\/\/(?:www.)?twitter.com\/([^ ?/]+)(?:\/status\/(\d+))?}
        end

        match self.regex, use_prefix: false, method: :twitter_url
        listen_to :connect, method: :setup

        def setup(m)
            unless Helpers.apis.apis.keys.include? "twitter"
                api = Twitter::REST::Client.new do |c|
                    c.consumer_key = Helpers.get_config["keys"]["twit_consumer_key"]
                    c.consumer_secret = Helpers.get_config["keys"]["twit_consumer_secret"]
                end
                Helpers.apis.setup_api "twitter", api
            end
        end

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
    end
end