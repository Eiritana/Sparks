module Helpers        
    class APIs
        def initialize
            @@apis = {}
        end

        def setup_api api, obj
            @@apis[api] = obj
        end

        def apis
            @@apis
        end
    end

    @@apis = APIs.new

    def apis
        @@apis
    end

    module_function :apis
end

module Main
    @@apis = Helpers.apis
    
    def apis
        @@apis
    end

    module_function :apis
end
