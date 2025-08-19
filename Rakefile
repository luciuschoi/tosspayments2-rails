# frozen_string_literal: true

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  warn 'RSpec not available; spec task skipped'
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  warn 'RuboCop not available; rubocop task skipped'
end

desc 'Generate YARD docs'
task :yard do
  sh 'bundle exec yard doc'
end

desc 'Run specs and RuboCop'
task quality: %i[rubocop spec]

namespace :release do
  desc 'Pre-release checks (clean git, specs, rubocop, changelog entry)'
  task :check do
    version_file = File.join(__dir__, 'lib', 'tosspayments2', 'rails', 'version.rb')
    version = File.read(version_file)[/VERSION = '([^']+)'/, 1]
    abort 'Uncommitted changes present' unless `git status --porcelain`.strip.empty?
    sh 'bundle exec rubocop'
    sh 'bundle exec rspec'
    changelog = File.read('CHANGELOG.md')
    abort 'CHANGELOG missing current version section' unless changelog.include?("[#{version}]")
    puts "Release checks passed for v#{version}"
  end
end

Rake::Task['release'].enhance(['release:check']) if Rake::Task.task_defined?('release')

task default: %i[quality]
