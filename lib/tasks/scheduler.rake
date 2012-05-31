desc "This task is called by the Heroku scheduler add-on"
task :update_sprints => :environment do
    puts "Updating sprints..."
    Sprint.reload
    puts "done."
end