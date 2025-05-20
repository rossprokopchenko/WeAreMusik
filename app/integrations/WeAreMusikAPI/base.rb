module WeAreMusikAPI
  class Base
    
    def initialize(params = {})
      # @access_token = params[:access_token]
    end

    def base_url
      "http://localhost:8000"
    end

    def request(method, path, options = {})

      response = HTTP.use(logging: { logger: Logger.new(STDOUT) })
        .headers({
          "User-Agent" => "Clipflow",
        })
        .timeout(connect: 5, read: 10, write: 10)
        .send(method, request_url(path), params: options[:params])

      # puts "Response: #{response}"

      return response

      rescue HTTP::ConnectionError => e
        Rails.logger.error("Connection error: #{e.message}")
      rescue HTTP::TimeoutError => e
        Rails.logger.error("Timeout error: #{e.message}")
      rescue HTTP::RequestError => e
        Rails.logger.error("Request error: #{e.message}")
      rescue StandardError => e
        Rails.logger.error("Unexpected error: #{e.message}")

    end

    def request_url(path)
      "#{base_url}#{path}"
    end

  end
end