module URL
    class Title
        include Cinch::Plugin

        def self.setup_needed
            true
        end
        
        def self.apis
            ["title"]
        end
        
        listen_to :connect, method: :overrides_setup
        match %r{(https?://.*?)(?:\s|$|,|\.\s|\.$)}, use_prefix: false, method: :title_url
    
        def overrides_setup(m)
            @@overrides = URL.constants.select{ |plugin| plugin.to_s != self.class.to_s.split("::")[1] }.map { |plugin|
                Kernel.const_get("#{self.class.parent.to_s}::#{plugin.to_s}")
            }
        end

        def title_url(m, url)
            @@overrides.each { |plugin|
                if url.match(plugin.regex)
                    return
                end
            }
            
            uri  = URI.parse(url)
            page = bot.apis["title"].get(uri)
            title = page.title.gsub(/[\x00-\x1f]*/, "").gsub(/[ ]{2,}/, " ").strip rescue nil
            m.reply "[\x0315URL\x03] %s (at %s)" % [ title, uri.host ] if title
        end
    end
end