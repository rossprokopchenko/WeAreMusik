module WeAreMusikAPI
  module Services
    class GetAccessToken

      def initialize(params = {})
        @platform_account = params[:platform_account]  
      end

      def perform
      
        if !@platform_account.expired?
          return { success: true, data: @platform_account.access_token }
        end

        refresh_result = refresh_token(@platform_account)
        if !refresh_result[:success]
          return refresh_result
        end

        @platform_account = update_platform_account(@platform_account, refresh_result)

        return { success: true, data: @platform_account.access_token }
      
      end

      private

        def refresh_token(platform_account)
          result = HTTP.use(logging: { logger: Logger.new(STDOUT) })
            .headers({
              "User-Agent" => "Clipflow",
            })
            # Link to where to get the token here - google oauth2 put here as placeholder
            .post("https://oauth2.googleapis.com/token", form: {
              # Parameters to get token
            })

          return result
        end

    end
  end
end
