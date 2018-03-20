module Social
    class YouTube
        include Cinch::Plugin

        def self.setup_needed
            true
        end
        
        def self.apis
            ["yt"]
        end

        match %r{http(?:s)?:\/\/(?:www.)?youtube.com\/(?:watch\?v=(.*)|channel\/(.*))}, use_prefix: false, method: :youtube_url

        def youtube_url(m, video_id, channel_id)
            if channel_id != nil    
                channel = bot.apis["yt"]::Channel.new id: channel_id

                m.reply("[\x0304YouTube\x03] #{channel.title} - Videos: #{channel.video_count} - Subscribers: #{channel.subscriber_count}")
            elsif video_id != nil
                video = bot.apis["yt"]::Video.new id: video_id
                puts video
                m.reply("[\x0304YouTube\x03] \"#{video.title}\" by #{video.channel_title} from #{video.published_at.strftime("%F %R")} - #{video.length} - Views: #{video.view_count} - \x0303⬆#{video.like_count} \x0304⬇#{video.dislike_count}\x03 - Comments: #{video.comment_count}")
            end
        end
    end
end