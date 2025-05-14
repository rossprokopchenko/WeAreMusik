# class FetchTracksJob
#   include Sidekiq::Job

#   def perform(*args)
#     # Do something later
#     fetchTracksObj = WeAreMusikAPI::Services::FetchTracks.new()

#     trackResponse = fetchTracksObj.perform

#     # puts trackResponse[:data].first

#     return trackResponse
#   end
# end