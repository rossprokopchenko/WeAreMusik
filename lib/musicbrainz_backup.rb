require 'open3'

class MusicbrainzBackup
  def initialize(vps_user:, vps_host:, vps_path:)
    @vps_user = vps_user
    @vps_host = vps_host
    @vps_path = vps_path.chomp('/')

    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "musicbrainz").configuration_hash
    @db_user = config[:username]
    @db_password = config[:password]
    @db_host = config[:host] || "localhost"
    @db_port = config[:port] || 5432
    @database = config[:database]

    @timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    @dump_filename = "backup_#{@database}_#{@timestamp}.dump"
    @compressed_filename = "#{@dump_filename}.gz"
  end

  def perform
    dump_database
    compress_dump
    upload_dump
    setup_pgpass
    create_remote_db
    restore_remote_db
    log "Backup, upload, remote DB creation, restore, and .pgpass setup completed successfully."
  rescue => e
    log "Backup failed: #{e.message}"
    raise
  end

  private

  def log(msg)
    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}"
  end

  def run_cmd(cmd)
    log "Running: #{cmd}"
    stdout, stderr, status = Open3.capture3(cmd)
    unless status.success?
      log "Error: #{stderr.strip}"
      raise "Command failed: #{cmd}"
    end
    log "Success: #{stdout.strip}" unless stdout.strip.empty?
    stdout
  end

  def dump_database
    log "Creating pg_dump for '#{@database}'..."
    ENV['PGPASSWORD'] = @db_password if @db_password

    dump_cmd = [
      "pg_dump",
      "-U", @db_user,
      "-h", @db_host,
      "-p", @db_port.to_s,
      "-F", "c",
      "-f", @dump_filename,
      @database
    ].join(" ")

    run_cmd(dump_cmd)

    ENV['PGPASSWORD'] = nil
  end

  def compress_dump
    log "Compressing dump file..."
    run_cmd("gzip -f #{@dump_filename}")
  end

  def upload_dump
    log "Uploading #{@compressed_filename} to #{@vps_user}@#{@vps_host}:#{@vps_path}..."
    run_cmd("scp #{@compressed_filename} #{@vps_user}@#{@vps_host}:#{@vps_path}/")
  end

  def setup_pgpass
    pgpass_line = "#{@db_host}:#{@db_port}:#{@database}:#{@db_user}:#{@db_password}"
    setup_cmd = <<~BASH.strip
      grep -qxF '#{pgpass_line}' ~/.pgpass 2>/dev/null || echo '#{pgpass_line}' >> ~/.pgpass && chmod 600 ~/.pgpass
    BASH

    ssh_cmd = "ssh #{@vps_user}@#{@vps_host} \"#{setup_cmd}\""
    log "Setting up .pgpass on remote VPS securely..."
    run_cmd(ssh_cmd)
  end

  def create_remote_db
    create_db_cmd = <<~SQL.strip
      psql -U #{@db_user} -d postgres -tc "SELECT 1 FROM pg_database WHERE datname='#{@database}';" | grep -q 1 || createdb -U #{@db_user} #{@database}
    SQL

    ssh_cmd = "ssh #{@vps_user}@#{@vps_host} \"#{create_db_cmd}\""
    log "Checking remote DB existence and creating if needed..."
    run_cmd(ssh_cmd)
  end

  def restore_remote_db
    remote_file_path = File.join(@vps_path, @compressed_filename)
    restore_cmd = "gunzip -c #{remote_file_path} | pg_restore -U #{@db_user} -d #{@database} --clean --if-exists"
    ssh_cmd = "ssh #{@vps_user}@#{@vps_host} \"#{restore_cmd}\""
    log "Restoring dump on remote server..."
    run_cmd(ssh_cmd)
  end
end
