require 'test/unit'

class MultipleRails < Test::Unit::TestCase
  
  def test_multiple_background_processes
    (1..10).each do |i|
      job = fork do
        exec "/bin/bash -l -c \"rails server -p #{9999+i}\""
      end
      puts job.inspect
      Process.detach(job)
    end
  end
end
