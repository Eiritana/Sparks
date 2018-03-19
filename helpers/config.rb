module Helpers
    def setup_config
        configFile = File.read("config.yaml")
        @@config = YAML.load(configFile)
        puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [config loader] Config loaded."
    end
    
     def get_config
       @@config
    end
    
    module_function :setup_config, :get_config
    
    setup_config
end

module Main
    @@config = Helpers.get_config
end
