# This file is used by Rack-based servers to start the application.
ENV['RUBY_HOME']="/home/tekniklr/.rvm/wrappers/ruby-3.2.2"
ENV['GEM_HOME']="/home/tekniklr/.rvm/gems/ruby-3.2.2"
ENV['GEM_PATH']="#{ENV['GEM_HOME']}"
require 'rubygems'

require ::File.expand_path('../config/environment',  __FILE__)
Gem.clear_paths

run Rails.application
