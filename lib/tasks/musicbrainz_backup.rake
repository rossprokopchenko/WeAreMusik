require_relative '../../lib/musicbrainz_backup'

namespace :musicbrainz do
  desc "Backup musicbrainz DB, upload, create remote DB if missing, restore and setup .pgpass securely"
  task :backup_upload_restore_secure, [:vps_user, :vps_host, :vps_path] => :environment do |t, args|
    unless args.vps_user && args.vps_host && args.vps_path
      puts "Usage: rake musicbrainz:backup_upload_restore_secure[vps_user,vps_host,vps_path]"
      exit 1
    end

    backup = MusicbrainzBackup.new(
      vps_user: args.vps_user,
      vps_host: args.vps_host,
      vps_path: args.vps_path
    )
    backup.perform
  end
end