require "airbrussh"
require "colorize"
require "sshkit/formatter/airbrussh"

# airbrush/capistrano uses a different default configuration
Airbrussh.configure do |config|
  config.log_file = "log/capistrano.log"
  config.monkey_patch_rake = true
  config.color = :auto
  config.truncate = :auto
end

module Airbrussh
  module Capistrano
    def self.load_into(configuration)
      configuration.load do
        after 'load',  'airbrussh:load_format'
        after 'deploy:failed', 'airbrussh:deploy_failed'

        namespace :airbrussh do
          task :load_format do
            set :format, :airbrussh
          end

          task :deploy_failed do
            output = env.backend.config.output
            output.on_deploy_failure if output.respond_to?(:on_deploy_failure)
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  ::Airbrussh::Capistrano.load_into(Capistrano::Configuration.instance)
end
