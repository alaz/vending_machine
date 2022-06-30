# frozen_string_literal: true

desc 'Start a console'
task :console do
  require 'irb'
  require './lib/vending_machine'
  ARGV.clear
  IRB.start
end
