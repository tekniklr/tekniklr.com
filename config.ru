# This file is used by Rack-based servers to start the application.
ENV['RUBY_HOME']="/home/tekniklr/.rbenv/versions/3.1.1"
ENV['GEM_HOME']="#{ENV['RUBY_HOME']}/lib/ruby/gems/3.1.0/gems"
ENV['GEM_PATH']="#{ENV['GEM_HOME']}"
require 'rubygems'

require ::File.expand_path('../config/environment',  __FILE__)
Gem.clear_paths

run Rails.application
