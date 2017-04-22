#!/usr/bin/env rake
# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

RuboCop::RakeTask.new

desc 'Run tests'
task :default do
  Rake::Task['rubocop'].invoke
  Rake::Task['test'].invoke
end
