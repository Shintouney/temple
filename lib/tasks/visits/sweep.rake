namespace :visits do
  task sweep: :environment do
    Raven.capture do
      Visit::Sweeper.new.execute
    end
  end
end
