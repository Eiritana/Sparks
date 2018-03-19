require 'yt'
require 'twitter'
require 'github_api'
require 'mechanize'

class URLHandler
    include Cinch::Plugin

    match %r{(https?://.*?)(?:\s|$|,|\.\s|\.$)}, :use_prefix => false

    @@setup = {
        :yt => false,
        :twit => false,
        :gh => false,
        :url => false
    }
    
    def execute(m, url)
        # youtube videos
        if config[:yt_key] and url.match(%r{(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})}) do |match|
            unless @@setup[:yt]
                Yt.configure do |c|
                    c.log_level = :debug
                    c.api_key = config[:yt_key]
                end
                @@setup[:yt] = true
            end
            video = Yt::Video.new id: match[1]
            m.reply("[\x0302URL/YT\x03] \"#{video.title}\" by #{video.channel_title} from #{video.published_at.strftime("%F %R")} - #{video.length} - ▶#{video.view_count} \x0303⬆#{video.like_count} \x0304⬇#{video.dislike_count}\x03 💬#{video.comment_count}")
            end 
        # twitter profiles
        elsif config[:twitter_consumer_key] and config[:twitter_consumer_secret] and url.match(%r{http(?:s)?:\/\/(?:www\.)?twitter.com\/([^ /?]+)(?:\/)?}) do |match|
            unless @@setup[:twit]
                @@client = Twitter::REST::Client.new do |c|
                    c.consumer_key = config[:twit_consumer_key]
                    c.consumer_secret = config[:twit_consumer_secret]
                end
                @@setup[:twit] = true
            end
            user = @@client.user(match[1].downcase)
            
            if user.location != nil
                location = " - 🗺️ #{user.location}"
            else
                description = ""
            end
            if user.description != nil
                description = " - \"#{user.description.gsub(/\R+/, ' ')}\""
            else
                description = ""
            end
            m.reply("[\x0302URL/Twitter\x03] #{user.name} (@#{user.screen_name})#{location}#{description} - 👥#{user.friends_count}/#{user.followers_count}")
            end
        # twitter posts
        elsif config[:twitter_consumer_key] and config[:twitter_consumer_secret] and url.match(%r{https?://(?:www\.)?twitter.com/[^/]+/status/(\d+)}) do |match|
            unless @@setup[:twit]
                @@client = Twitter::REST::Client.new do |c|
                    c.consumer_key = config[:twit_consumer_key]
                    c.consumer_secret = config[:twit_consumer_secret]
                end
                @@setup[:twit] = true
            end
            tweet = @@client.status(match[1])
            
            m.reply("[\x0302URL/Twitter\x03] \"#{tweet.text}\" by #{tweet.user.name} (@#{tweet.user.screen_name}) from #{tweet.created_at.strftime("%F %R")} - 🔁#{tweet.retweet_count} ❤️#{tweet.favorite_count}")
            end
        # github repositories
        elsif config[:gh_key] and config[:gh_secret] and url.match(%r{http(?:s)?:\/\/(?:www\.)?github.com\/([^ /?]+)\/([^ /?]+)}) do |match|
            unless @@setup[:gh]
                Github.configure do |c|
                    c.client_id = config[:gh_key]
                    c.client_secret = config[:gh_secret]
                end
                @@setup[:gh] = true
            end
            repos = Github::Client::Repos.new
            repo = repos.get user: match[1], repo: match[2]
            m.reply "[\x0302URL/GitHub\x03] #{repo.full_name} - \"#{repo.description}\" - Last Commit: #{repo.pushed_at.to_time.strftime("%F %R")} - ↻#{repo.forks_count} ⭐#{repo.stargazers_count} 👁️#{repo.watchers_count} - ⚠️#{repo.open_issues_count}"
            end
        # github gists
        elsif config[:gh_key] and config[:gh_secret] and url.match(%r{http(?:s)?:\/\/gist.github.com\/([^ /?]+)\/([^ /?]+)}) do |match|
                unless @@setup[:gh]
                    Github.configure do |c|
                        c.client_id = config[:gh_key]
                        c.client_secret = config[:gh_secret]
                    end
                    @@setup[:gh] = true
                end
                gists = Github::Client::Gists.new
                gist = gists.get id: match[2]
                if gist.description != ""
                    description = " - \"#{gist.description}\""
                end
                m.reply "[\x0302URL/Gists\x03] #{gist.owner.login})/#{gist.files.to_hash.values[0]["filename"]}#{description} - Last Update: #{gist.updated_at.to_time.strftime("%F %R")} - \"#{gist.files.to_hash.values[0]["content"]}\""
            end
        # github profiles
        elsif config[:gh_key] and config[:gh_secret] and url.match(%r{http(s)?:\/\/(www\.)?github\.com/([A-z 0-9 _ -]+\/?)}) do |match|
                unless @@setup[:gh]
                    Github.configure do |c|
                        c.client_id = config[:gh_key]
                        c.client_secret = config[:gh_secret]
                    end
                    @@setup[:gh] = true
                end
                users = Github::Client::Users.new
                puts match[3]
                user = users.get user: match[3]
                
                if user.location != ""
                    location = " - 🗺️ #{user.location}"
                else
                    location = ""
                end
                if user.bio != ""
                    bio = " - \"#{user.bio}\""
                else
                    bio = ""
                end
                
                m.reply "[\x0302URL/Github\x03] #{user.name} (#{user.login})#{location} #{bio} - 📁#{user.public_repos} 📚#{user.public_gists}"
            end
        # regular title grabber
        else
            unless @@setup[:url]
                @agent = Mechanize.new
            end
            uri  = URI.parse(url)
            page = @agent.get(uri)
            title = page.title.gsub(/[\x00-\x1f]*/, "").gsub(/[ ]{2,}/, " ").strip rescue nil
            m.reply "[\x0302URL\x03] %s (at %s)" % [ title, uri.host ] if title
        end
    end
end
