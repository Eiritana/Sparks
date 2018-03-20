class Title
    include Cinch::Plugin

    def self.setup_needed
        true
    end
    
    def self.apis
        ["title"]
    end

    match %r{(https?://.*?)(?:\s|$|,|\.\s|\.$)}, use_prefix: false, method: :title_url

    def title_url(m, url)
        overrides = bot.config.plugins.plugins.map { |plugin| plugin.to_s } & ["Social::Twitter", "Social::GitHub", "Social::YouTube"]
        
        regexes = {
            "Social::Twitter" => %r{http(?:s)?:\/\/(?:www.)?twitter.com\/([^ ?/]+)(?:\/status\/(\d+))?},
            "Social::Github" => %r{http(?:s)?:\/\/(?:(www|gist).)?github.com\/([^ /?]+)(?:\/)?([^ /?]+)?},
            "Social::YouTube" => %r{http(?:s)?:\/\/(?:www.)?youtube.com\/(?:watch\?v=(.*)|channel\/(.*))} 
        }

        regexes.each { |plugin_name, regex|
            if url.match(regex)
                return
            end
        }
        uri  = URI.parse(url)
        page = bot.apis["title"].get(uri)
        title = page.title.gsub(/[\x00-\x1f]*/, "").gsub(/[ ]{2,}/, " ").strip rescue nil
        m.reply "[\x0315URL\x03] %s (at %s)" % [ title, uri.host ] if title
    end
end