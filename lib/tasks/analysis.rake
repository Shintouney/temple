begin
  require 'flog'
  require 'flog_cli'
  require 'rubocop/rake_task'

  namespace :analysis do

    desc 'Run RuboCop on the lib directory'
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.patterns = ['app/models/**.rb', 'app/extensions/**/*.rb', 'app/services/**/*.rb', 'lib/tasks/**/*.rb']
      task.formatters = ['progress']
      task.fail_on_error = false
      task.options = ["--config", ".rubocop.yml", "--force-exclusion"]
    end

    namespace :flog do
      desc "Analyze total code complexity with flog"
      task :total do
        threshold = 3500
        flogger = FlogCLI.new(FlogCLI.parse_options)
        flogger.flog %w(app lib)

        if flogger.total_score > threshold
          fail "Flog total complexity is too high: #{flogger.total_score} > #{threshold}"
        end
      end

      desc "Analyze for average code complexity"
      task :average do
        threshold = 20
        flogger = FlogCLI.new(FlogCLI.parse_options)
        flogger.flog %w(app lib)

        fail "Flog average complexity is too high: #{flogger.average} > #{threshold}" if flogger.average > threshold
      end

      desc "Analyze for individual code complexity"
      task :each do
        threshold = 33
        flogger = FlogCLI.new(FlogCLI.parse_options(['-m']))
        flogger.flog %w(app lib)

        bad_methods = flogger.instance_variable_get('@flog').totals.select do |name, score|
          score > threshold
        end

        unless bad_methods.empty?
          bad_methods.to_a.sort_by! { |name, score| -score }.each do |name, score|
            puts "%8.1f: %s" % [score, name]
          end

          fail "#{bad_methods.size} methods have a flog complexity >#{threshold}"
        end
      end
    end
  end
rescue LoadError
end
