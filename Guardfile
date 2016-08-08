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
  RunningProcess[:gen_rb] = ChildProcess.build("ruby", "webrick.rb")
  RunningProcess[:gen_rb].io.inherit!
  RunningProcess[:gen_rb].start
  nil
end

# If some file path are provided as ARGV for gen.rb, only those files will be preprocessed
# Otherwise, everything will be compiled
def compile(changed_file_paths=[])
  `ruby gen.rb #{changed_file_paths.join(" ")}`
end

# Start the server even if no file has changed.
compile
start_server

guard 'livereload' do
  watch /^dist.+/
end

# The guard-shell gem runs a block whenever some set of files has changed.
guard :shell do
  # This regex matches anything except the dist/ folder
  watch /.+/ do |m|
    path = m.instance_variable_get("@original_value").to_s
    if !Pathname.new(path).exist?
      compile # recompile everything when a file is deleted
    elsif !(path.include?("dist/"))
      if path.include?("Gemfile")
        ensure_exited_server
        `bundle`
        compile
        start_server
      else
        compile([path])
      end
    end
    # Print a little message when a file changes.
    m[0] + " has changed."
  end
  nil
end


# Make sure the server does not run after guard exits
at_exit { ensure_exited_server }