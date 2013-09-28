$:.push File.expand_path('../lib', __FILE__)
require 'rubygems'

require 'bundler/setup'

require 'rake/testtask'
require 'thor/rake_compat'

class Default < Thor
  class Gem < Thor
    namespace :gem

    include Thor::RakeCompat
    Bundler::GemHelper.install_tasks

    desc "build", "Build knife-annex-#{KnifeAnnex::VERSION}.gem into the pkg directory"
    def build
      Rake::Task["build"].execute
    end

    desc "release", "Create tag v#{KnifeAnnex::VERSION} and build and push knife-annex-#{KnifeAnnex::VERSION}.gem to Rubygems"
    def release
      Rake::Task["release"].execute
    end

    desc "install", "Build and install knife-annex-#{KnifeAnnex::VERSION}.gem into system gems"
    def install
      Rake::Task["install"].execute
    end
  end
end

