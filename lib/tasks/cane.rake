begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics and code coverage"
  Cane::RakeTask.new(:quality) do |cane|
    cane.add_threshold 'coverage/.last_run.json', :>=, 99
    cane.abc_glob = '{app,lib}/**/*.rb'
    cane.abc_max = 30
    cane.no_style = true
    cane.no_doc = true
  end
rescue LoadError
end
