#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

desc "Run tests"
task :default => :test