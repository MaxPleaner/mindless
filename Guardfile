require 'childprocess'

# Global constant tracking whether the server has been started
RunningProcess = {gen_rb: false}

# Method to stop the server if it's been started
def ensure_exited_server
  begin
    RunningProcess[:gen_rb] && RunningProcess[:gen_rb].poll_for_exit(10)
  rescue ChildProcess::TimeoutError
    RunningProcess[:gen_rb].stop # tries increasingly harsher methods to kill the process.
  end
  RunningProcess[:gen_rb] = false
  nil
end

# Start the server using 'child-process'
def start_server
  # prevent 'port in use' errors
  ensure_exited_server
  # The child-process gem starts a process and exposes its stdout
  RunningProcess[:gen_rb] = ChildProcess.build("ruby", "gen.rb")
  RunningProcess[:gen_rb].io.inherit!
  RunningProcess[:gen_rb].start
  nil
end

# Start the server even if no file has changed.
start_server

# The guard-shell gem runs a block whenever some set of files has changed.
guard :shell do
  # This regex matches anything except the dist/ folder
  watch /.+/ do |m|
    path = m.instance_variable_get("@original_value")
    if !(path.to_s.include?("dist/"))
      if path.include?("Gemfile")
        ensure_exited_server
        `bundle`
      end
      start_server
    end
    # Print a little message when a file changes.
    m[0] + " has changed."
  end
  nil
end


# Make sure the server does not run after guard exits
at_exit { ensure_exited_server }