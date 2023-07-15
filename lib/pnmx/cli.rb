module Pnmx::Cli
  class LockError < StandardError; end
  class HookError < StandardError; end
end

# SSHKit uses instance eval, so we need a global const for ergonomics
MRSK = Pnmx::Commander.new
