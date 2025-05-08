module WeAreMusikAPI
  class Tracks < Base

    def get_tracks(options = {})

      params = {

      }.merge(options[:params] || {})

      result = request(:get, "/tracks", {
        params: params,
      })

      parsed_result = IntegrationsBase.parse_json_response(result)
      return parsed_result if !parsed_result[:success]

      return parsed_result

      if result.status.success?
        return {
          success: true,
          data: parsed_result[:data]
        }
      end

      return {
        success: false,
        errors: parsed_result[:errors]
      }

    end 

  end
end