# frozen_string_literal: true

require 'rake/testtask'

# Tasks
namespace :foreman_netbox do
  namespace :example do
    desc 'Example Task'
    task task: :environment do
      # Task goes here
    end
  end
end

# Tests
namespace :test do
  desc 'Test ForemanNetbox'
  Rake::TestTask.new(:foreman_netbox) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_netbox do
  task rubocop: :environment do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_netbox) do |task|
        task.patterns = ["#{ForemanNetbox::Engine.root}/app/**/*.rb",
                         "#{ForemanNetbox::Engine.root}/lib/**/*.rb",
                         "#{ForemanNetbox::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_netbox'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_netbox']

load 'tasks/jenkins.rake'

# rubocop:disable Style/IfUnlessModifier
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance ['test:foreman_netbox', 'foreman_netbox:rubocop']
end
# rubocop:enable Style/IfUnlessModifier
