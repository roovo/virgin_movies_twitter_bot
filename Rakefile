require 'rubygems'

task :default => :spec

desc "Run specs"
task :spec do
  sh "spec spec/*.rb --color"
end

# to save a tag: git tag -a v0.2.2 -m "BUGFIX: should tweet again & expire properly"
namespace :git do
  desc "Push changes to remote repos"
  task :push_tags do
    sh "git push github --tags" # Github
  end
end