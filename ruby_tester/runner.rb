require 'excon'
require 'concurrent'
require 'json'

class Threader
  class << self
    def perform(spread=2, max=225)
      promises = []
      (0..spread).to_a.each do |i|
        promises << Concurrent::Promise.execute { Runner.new.perform(max) }
      end
      Concurrent::Promise.zip(*promises).value!
    end
  end
end

class Runner
    include Concurrent::Async

    attr_reader :res, :time_to_end

    def initialize
      @res = []
      @time_to_end = 0
    end

    def perform(max=225)
      start = Time.now
      @res = (1..max).to_a.map { |_| async.request }.map(&:value)
      stop = Time.now
      @time_to_end = stop - start
      @res
    end

    def request
      Requester.run_request
    end
end

class Requester

  CHARS = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
  LEN = CHARS.length.freeze

  class << self
    def run_request
      res = Excon.post \
        'http://localhost:4000/account',
        body: random_body.to_json,
        headers: {'Content-Type' => 'application/json'}
      res.body
    end

    def random_body
      f = rand_word
      l = rand_word
      {
        first_name: f,
        last_name: l,
        email:"#{f}.#{l}@gmail.com"
      }
    end

    def rand_word
      (0...5).map { CHARS[rand(LEN)] }.join
    end
  end
end


spread = \
  if ARGV[0].to_i > 0
    ARGV[0].to_i
  else
    10
  end
range = \
  if ARGV[1].to_i > 0
    ARGV[1].to_i
  else
    1000
  end

start = Time.now
Threader.perform(spread, range)
stop = Time.now
time_to_end = stop - start

puts "ran #{range*spread} concurrent requests took #{time_to_end} seconds"
