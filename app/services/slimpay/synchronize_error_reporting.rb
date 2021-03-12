module Slimpay
  class SynchronizeErrorReporting

    def initialize
      @host = Settings.slimpay.sftp.host
      @login = Settings.slimpay.sftp.login
      @options = Settings.slimpay.sftp.to_hash.slice(:port, :keys)
    end

    def execute
      begin
        @tmpdir = Dir.mktmpdir('slimpayerrorreporting')
        retrieve_remote_csv
      rescue => exception
        report_exception(exception)
        raise exception
      ensure
        FileUtils.rm_rf(@tmpdir)
      end
    end

    private

      # How to use it in console
      #
      # @host = Settings.slimpay.sftp.host
      # @login = Settings.slimpay.sftp.login
      # @options = Settings.slimpay.sftp.to_hash.slice(:port, :keys)
      # sftp = Net::SFTP.start(@host, @login, @options)
      # @tmpdir = Dir.mktmpdir('slimpayerrorreporting')
      # sftp.dir.foreach("/out") do |entry|
      #   puts "dl #{entry.name}"
      #   next if entry.name == "REJ-20171107-121531-436.csv" #TMP#
      #   @tmpfile_path = File.join(@tmpdir, File.basename(Pathname.new(Settings.slimpay.sftp.remote_directory).join(entry.name).to_s))
      #   File.write(@tmpfile_path, sftp.download!(Pathname.new(Settings.slimpay.sftp.remote_directory).join(entry.name).to_s))
      #   puts "parsing #{entry.name}"
      #   Slimpay::ErrorParser.new(@tmpfile_path).execute
      # end

    def retrieve_remote_csv
      Net::SFTP.start(@host, @login, @options) do |sftp|
        sftp.dir.foreach("/out") do |entry|
          if entry.name.include?('REJ') && Rtransaction.where(file_name: entry.name).blank?
            next if entry.name == "REJ-20171107-121531-436.csv"
            download!(sftp, entry.name)
            Slimpay::ErrorParser.new(@tmpfile_path).execute
            Rtransaction.create!(file_name: entry.name)
          end
        end
      end
    end

    def download!(sftp, name)
      @tmpfile_path = File.join(@tmpdir, File.basename(remote_file_path(name)))
      File.write @tmpfile_path, sftp.download!(remote_file_path(name))
    end

    def remote_file_path(file_name)
      Pathname.new(Settings.slimpay.sftp.remote_directory).join(file_name).to_s
    end

    def report_exception(exception)
      raven_event = Raven::Event.from_exception(exception)
      Raven.send(raven_event)
      # ErrorMailer.synchronize_download_failed(raven_event.id, exception.message).deliver_later
    end
  end
end
