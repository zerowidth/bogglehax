class ProcessManager
  def self.process(data_set, max_procs = 2, &blk)
    pipes = []
    results = []
    
    # start up initial set of processes
    max_procs.times { pipes << fork_worker(data_set.shift, &blk) unless data_set.empty? }

    until pipes.empty?
    
      begin
        Process.wait
      rescue Errno::ECHILD
        # ignore errors here
      end

      while ready = Kernel.select(pipes, nil, nil, 0.1) # with timeout just in case
        ready = ready.first # only the readable pipes plz

        ready.each do |pipe|
          result = pipe.gets
          if result
            # puts "got result from child: #{result}"
            results << result.strip
          else # nil, pipe closed
            pipe.close
            pipes.delete pipe
            puts "child done"#{}", #{pipes.size} pipes remain"
          end
                
        end # each pipe
      end # kernel select loop
      
      unless data_set.empty? # start new processes
        until pipes.size == max_procs || data_set.empty?
          data = data_set.shift
          pipes << fork_worker( data, &blk )
        end
      end

    end # until pipes.empty?
    
    return results
    
  end
  
  private
  
  def self.fork_worker(data)
    pipe = IO::popen('-', 'r') # fork!
    if pipe # in the parent
      puts "started child"#" with #{data}"
      return pipe
    else # in the child
      yield data
      exit
    end
  end
  
end

if $0 == __FILE__

res = ProcessManager.process([1,2.01,2.02,2.03,2.04,2.05], 3) do |data|
  sleep data
  puts data
end

p res

end