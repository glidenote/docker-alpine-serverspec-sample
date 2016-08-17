require 'serverspec'
require 'docker'

set :backend, :docker
set :docker_url, ENV["DOCKER_HOST"]
image = Docker::Image.build_from_dir('.')
set :docker_image, image.id

Excon.defaults[:ssl_verify_peer] = false

# https://circleci.com/docs/docker#docker-exec
if ENV['CIRCLECI']
  module Docker
    class Container
      def exec(command, opts = {}, &block)
        command[2] = command[2].inspect # ['/bin/sh', '-c', 'YOUR COMMAND']
        cmd = %Q{sudo lxc-attach -n #{self.id} -- #{command.join(' ')}}
        stdin, stdout, stderr, wait_thread = Open3.popen3 cmd
        [stdout.read, [stderr.read], wait_thread.value.exitstatus]
      end
      def remove(options={})
        # do not delete container
      end
      alias_method :delete, :remove
      alias_method :kill, :remove
    end
  end
end
