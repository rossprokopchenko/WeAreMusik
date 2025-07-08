
require 'net/http'
require 'uri'
require 'json'

# === Settings ===
# Replace these with real release_group MBIDs you want to test
release_group_mbids = [
  "8a01217e-6947-3927-a39b-6691104694f1"
]

puts "=== Starting Cover Art Archive Redirect Chain Test ==="


# === Helper ===
def follow_redirects(uri, limit = 5)
  raise "Too many redirects for #{uri}" if limit == 0

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")

  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  case response
  when Net::HTTPSuccess then
    uri
  when Net::HTTPRedirection then
    location = response['location']
    puts "  Redirected from #{uri} to #{location}"
    follow_redirects(URI.parse(location), limit - 1)
  else
    puts "  Unexpected response for #{uri}: #{response.code} #{response.message}"
    uri
  end
rescue => e
  puts "  Error during redirect for #{uri}: #{e.message}"
  nil
end

release_group_mbids.each do |mbid|
  puts "\n=== Testing ReleaseGroup MBID: #{mbid} ==="

  metadata_url = "https://coverartarchive.org/release-group/#{mbid}/"
  puts "  Metadata URL: #{metadata_url}"

  final_metadata_uri = follow_redirects(URI.parse(metadata_url))

  puts "  Final Metadata URI: #{final_metadata_uri}"

  next unless final_metadata_uri

  response = Net::HTTP.get_response(final_metadata_uri)

  if response.is_a?(Net::HTTPSuccess)
    json = JSON.parse(response.body)

    if json['images'] && !json['images'].empty?
      image = json['images'].find { |i| i['front'] } || json['images'].first
      image_url = image.dig('thumbnails', 'large') || image['image']

      puts "  Chosen Image URL: #{image_url}"

      if image_url
        final_image_uri = follow_redirects(URI.parse(image_url))
        puts "  Final Image URI: #{final_image_uri}"

        puts "  Host: #{final_image_uri.host}" if final_image_uri
      else
        puts "  No usable image URL found for MBID #{mbid}."
      end
    else
      puts "  No images found for MBID #{mbid}."
    end
  else
    puts "  Metadata request failed for MBID #{mbid} — HTTP #{response.code}"
  end
end

puts "\n=== Done ==="

