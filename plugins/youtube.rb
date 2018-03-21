require 'yt'

module URL
    class YouTubeAPI
        include Cinch::Plugin

        def self.required_config
            ["keys:yt_key"]
        end

        def self.regex
            %r{http(?:s)?:\/\/(?:www.)?youtube.com\/(?:watch\?v=(.*)|channel\/(.*))}
        end

        match self.regex, use_prefix: false, method: :youtube_url
        listen_to :connect, method: :setup

        def setup(m)
            unless Helpers.apis.apis.keys.include? "yt"
                api =  Yt.configure do |c|
                    c.api_key = Helpers.get_config["keys"]["yt_key"]
                end
                Helpers.apis.setup_api "yt", api
            end
        end

        def youtube_url(m, video_id, channel_id)
            if channel_id != nil    
                channel = Yt::Channel.new id: channel_id

                m.reply("[\x0304YouTube\x03] #{channel.title} - Videos: #{channel.video_count} - Subscribers: #{channel.subscriber_count}")
            elsif video_id != nil
                video = Yt::Video.new id: video_id
                m.reply("[\x0304YouTube\x03] \"#{video.title}\" by #{video.channel_title} from #{video.published_at.strftime("%F %R")} - #{video.length} - Views: #{video.view_count} - \x0303⬆#{video.like_count} \x0304⬇#{video.dislike_count}\x03 - Comments: #{video.comment_count}")
            end
        end
    end
end