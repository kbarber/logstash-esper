require 'esperfoo/mq'
require 'esperfoo/esper'
require 'esperfoo/statement'

module EsperFoo
  class Application
    def initialize(args)
      @args = args
    end

    def run
      # Create mq object
      mq = EsperFoo::Mq.new

      # Esper
      esper = EsperFoo::Esper.new(mq)
      statement = {
        :name => "count_every_5_seconds",
        :expression => "select count(*) as count from event.win:time_batch(5 sec) having count(*) > 0",
        :message => "Generated from statement: <%= statement[:name] %>. Found <%= match['count'] %> number of events in 5 seconds.",
      }
      esper.create_statement(statement)

      # MQ
      mq.subscribe
    end
  end
end
