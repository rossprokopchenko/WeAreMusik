class IntegrationsBase

  def self.parse_json_response(result)
    begin
     data = JSON.parse(result.body, symbolize_names: true)
     
     return {
      success: true,
      data: data,
     }
    rescue => e 
      return {
        success: false,
        errors: ["Could not parse response"],
      }
    end
  end
    

end