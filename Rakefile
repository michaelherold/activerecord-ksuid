# frozen_string_literal: true

require 'bundler/gem_tasks'

# Defines a Rake task if the optional dependency is installed
#
# @return [nil]
def with_optional_dependency
  yield if block_given?
rescue LoadError # rubocop:disable Lint/SuppressedException
end

default = %w[backport spec:sqlite]

desc 'Applies backports when necessary'
task :backport do
  if ENV['RAILS_VERSION'] == '5.0'
    patch = 'spec/support/patches/backport-mysql-fix.patch'
    sh <<~PATCH
      if ! patch -R -p1 -s -f --dry-run -d "$(gem env gemdir)"/gems/activerecord-5.0* <#{patch}; then
        patch -p1 -d "$(gem env gemdir)"/gems/activerecord-5.0* <#{patch}
      fi
    PATCH
  end
end

namespace :db do
  desc 'Reset all databases'
  task reset: %i[mysql:reset postgresql:reset]

  namespace :mysql do
    desc 'Reset MySQL database'
    task reset: %i[drop create]

    desc 'Create MySQL database'
    task :create do
      sh %(mysql -u root -e 'CREATE DATABASE `activerecord-ksuid_test`;')
    end

    desc 'Drops MySQL database'
    task :drop do
      sh %(mysql -u root -e 'DROP DATABASE IF EXISTS `activerecord-ksuid_test`;')
    end
  end

  namespace :postgresql do
    desc 'Reset PostgreSQL database'
    task reset: %i[drop create]

    desc 'Create PostgreSQL database'
    task :create do
      sh 'createdb -U postgres activerecord-ksuid_test'
    end

    desc 'Drops PostgreSQL database'
    task :drop do
      sh %(psql -d postgres -U postgres -c 'DROP DATABASE IF EXISTS "activerecord-ksuid_test"')
    end
  end
end

if ENV['APPRAISAL_INITIALIZED']
  require 'rspec/core/rake_task'

  namespace :spec do
    task all: %i[mysql postgresql sqlite]

    task :mysql do
      sh 'DRIVER=mysql2 DB_HOST=127.0.0.1 DB_USERNAME=root bundle exec rspec'
    end

    task :postgresql do
      sh 'DRIVER=postgresql DB_USERNAME=postgres bundle exec rspec'
    end

    task :sqlite do
      sh 'DRIVER=sqlite3 DATABASE=":memory:" bundle exec rspec'
    end
  end
else
  namespace :spec do
    task all: %i[mysql postgresql sqlite]

    task :mysql do
      run_rspec_with_driver('mysql2', { 'DB_HOST' => '127.0.0.1', 'DB_USERNAME' => 'root' })
    end

    task :postgresql do
      run_rspec_with_driver('postgresql', { 'DB_USERNAME' => 'postgres' })
    end

    task :sqlite do
      run_rspec_with_driver('sqlite3', { 'DATABASE' => ':memory:' })
    end

    def run_rspec_with_driver(driver, env = {})
      command = String.new('rspec')
      env['DRIVER'] = driver
      if (gemfile = ENV['BUNDLE_GEMFILE']) && gemfile.match?(%r{gemfiles/})
        env['BUNDLE_GEMFILE'] = gemfile
      else
        command.prepend('appraisal rails-6.0 ')
      end
      success = system(env, command)

      abort "\nRSpec failed: #{$CHILD_STATUS}" unless success
    end
  end
end

with_optional_dependency do
  require 'yard-doctest'
  task 'yard:doctest' do
    command = String.new('yard doctest')
    env = {}
    if (gemfile = ENV['BUNDLE_GEMFILE'])
      env['BUNDLE_GEMFILE'] = gemfile
    elsif !ENV['APPRAISAL_INITIALIZED']
      command.prepend('appraisal rails-6.0 ')
    end
    success = system(env, command)

    abort "\nYard Doctest failed: #{$CHILD_STATUS}" unless success
  end

  default << 'yard:doctest'
end

with_optional_dependency do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)

  default << 'rubocop'
end

with_optional_dependency do
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new(:yard)

  default << 'yard'
end

with_optional_dependency do
  require 'inch/rake'
  Inch::Rake::Suggest.new(:inch)

  default << 'inch'
end

with_optional_dependency do
  require 'yardstick/rake/measurement'
  options = YAML.load_file('.yardstick.yml')
  Yardstick::Rake::Measurement.new(:yardstick_measure, options) do |measurement|
    measurement.output = 'coverage/docs.txt'
  end

  require 'yardstick/rake/verify'
  options = YAML.load_file('.yardstick.yml')
  Yardstick::Rake::Verify.new(:yardstick_verify, options) do |verify|
    verify.threshold = 100
  end

  task yardstick: %i[yardstick_measure yardstick_verify]
end

if ENV['CI']
  task default: default
elsif !ENV['APPRAISAL_INITIALIZED']
  require 'appraisal/task'
  Appraisal::Task.new
  task default: default - %w[spec yard:doctest] + %w[appraisal]
else
  ENV['COVERAGE'] = '1'
  task default: default & %w[spec yard:doctest]
end
