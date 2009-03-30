require 'rubygems'

task :default => :spec

desc "Run specs"
task :spec do
  sh "spec spec/*.rb --color"
end

namespace :git do
  desc "Push changes to remote repos"
  task :push_tags do
    sh "git push github --tags" # Github
  end
end