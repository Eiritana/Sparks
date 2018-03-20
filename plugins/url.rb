class URLs
    include Cinch::Plugin

    def self.setup_needed
        true
    end
    
    def self.apis
        ["twitter", "github", "yt", "title"]
    end
    
    set :help, <<-EOF
[\x0307Help\x03] URLs - Parses URLs and detects what service they are and uses an API to fetch data or just fetches the page title.
    EOF
    
    match %r{(https?://.*?)(?:\s|$|,|\.\s|\.$)}, :use_prefix => false
    listen_to :connect, method: :setup_help
    
    def setup_help(m)
        self.class.help = <<-EOF
[\x0307Help\x03] URLs - Parses URLs and detects what service they are and uses an API to fetch data or just fetches the page title.
[\x0307Help\x03] Services: #{(self.class.apis & Main.apis.keys).join(", ")}.
        EOF
    end
    
    def execute(m, url)
        # youtube videos
        if bot.apis["yt"] and url.match(%r{(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})}) do |match|
            video = bot.apis["yt"]::Video.new id: match[1]
            m.reply("[\x0302URL/YT\x03] \"#{video.title}\" by #{video.channel_title} from #{video.published_at.strftime("%F %R")} - #{video.length} - ▶#{video.view_count} \x0303⬆#{video.like_count} \x0304⬇#{video.dislike_count}\x03 💬#{video.comment_count}")
            end 
        # twitter profiles
        elsif bot.apis["twitter"] and url.match(%r{http(?:s)?:\/\/(?:www\.)?twitter.com\/([^ /?]+)(?:\/)?}) do |match|
            user = bot.apis["twitter"].user(match[1].downcase)
            
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
        elsif bot.apis["twitter"] and url.match(%r{https?://(?:www\.)?twitter.com/[^/]+/status/(\d+)}) do |match|
            tweet = @@client.status(match[1])
            
            m.reply("[\x0302URL/Twitter\x03] \"#{tweet.text}\" by #{tweet.user.name} (@#{tweet.user.screen_name}) from #{tweet.created_at.strftime("%F %R")} - 🔁#{tweet.retweet_count} ❤️#{tweet.favorite_count}")
            end
        # github repositories
        elsif bot.apis["github"] and url.match(%r{http(?:s)?:\/\/(?:www\.)?github.com\/([^ /?]+)\/([^ /?]+)}) do |match|
            repos = bot.apis["github"]::Client::Repos.new
            repo = repos.get user: match[1], repo: match[2]
            m.reply "[\x0302URL/GitHub\x03] #{repo.full_name} - \"#{repo.description}\" - Last Commit: #{Time.parse(repo.pushed_at).strftime("%F %R")} - ↻#{repo.forks_count} ⭐#{repo.stargazers_count} - ⚠️#{repo.open_issues_count}"
            end
        # github gists
        elsif bot.apis["github"] and url.match(%r{http(?:s)?:\/\/gist.github.com\/([^ /?]+)\/([^ /?]+)}) do |match|
                gists = bot.apis["github"]::Client::Gists.new
                gist = gists.get id: match[2]
                if gist.description != ""
                    description = " - \"#{gist.description}\""
                end
                m.reply "[\x0302URL/Gists\x03] #{gist.owner.login}/#{gist.files.to_hash.values[0]["filename"]}#{description} - Last Update: #{Time.parse(gist.updated_at).strftime("%F %R")} - \"#{gist.files.to_hash.values[0]["content"]}\""
            end
        # github profiles
        elsif bot.apis["github"] and url.match(%r{http(s)?:\/\/(www\.)?github\.com/([A-z 0-9 _ -]+\/?)}) do |match|
                users = bot.apis["github"]::Client::Users.new
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
        elsif bot.apis["title"]
            uri  = URI.parse(url)
            page = bot.apis["title"].get(uri)
            title = page.title.gsub(/[\x00-\x1f]*/, "").gsub(/[ ]{2,}/, " ").strip rescue nil
            m.reply "[\x0302URL\x03] %s (at %s)" % [ title, uri.host ] if title
        end
    end
end
