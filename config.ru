if defined?(Unicorn)
require 'unicorn'
require 'unicorn/worker_killer'

oom_min = (300) * (10242)
oom_max = (320) * (10242)

use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
