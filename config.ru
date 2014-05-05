# This file is used by Rack-based servers to start the application.
ENV['MY_RUBY_HOME']="/home/tekniklr/.rvm/rubies/ruby-1.8.7-p374"
ENV['GEM_HOME']="/home/tekniklr/.rvm/gems/ruby-1.8.7-p374"
ENV['GEM_PATH']="#{ENV['GEM_HOME']}:/usr/lib/ruby/gems/1.8"
require 'rubygems'

require ::File.expand_path('../config/environment',  __FILE__)
Gem.clear_paths

run TekniklrCom::Application
