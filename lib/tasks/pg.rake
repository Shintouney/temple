namespace :pg do

  desc 'Dump DB and scp it to backup server.'
  task backup: :environment do
    time_tag = Time.now.strftime('%Y%m%d_%Hh%M')
    file_name = nil
    with_config do |app, host, db, user|
      file_name = "~/dump_#{app}_#{Rails.env}_#{time_tag}.dump"
      options = "--no-password --verbose --clean --no-owner"
      %x{ RAILS_ENV=#{Rails.env} pg_dump --host=#{host} --username=#{user} --port=5432 --format=c -d #{db} -f #{file_name} #{options} }
    end
    Rake::Task['pg:scp'].invoke(file_name)
    Rake::Task['pg:clean_backups'].invoke(5)
  end

  desc 'SCP given filename to the BD backup server'
  task :scp, [:file_name] => :environment do |t, args|
    %x{scp -i ~/.ssh/id_rsa #{args[:file_name]} jb@backup.novagile.fr:~/temple/}
  end

  desc 'Clean N old dumps. nb_keep indicate the number of dumps to keep'
  task :clean_backups, [:nb_keep] => :environment do |t, args|
    dump_files = Dir.entries(Dir.home).select{|file_name| file_name.match(/dump_/) }
    keep = dump_files.pop(args[:nb_keep])

    (dump_files - keep).each do |file_name|
      File.delete("#{Dir.home}/#{file_name}")
    end
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end
end
