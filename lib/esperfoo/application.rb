require 'esperfoo/mq'
require 'esperfoo/esper'

module EsperFoo
  class Application
    def initialize(args)
      @args = args
    end

    def run
      # Create mq object
      mq = EsperFoo::Mq.new

      # Esper object
      esper = EsperFoo::Esper.new(mq)

      # Lets create a new statement
      # TODO: statement creation should be from a configuration file
      statement = {
        :name => "count_every_15_seconds",
        :expression => "select count(*) as count from event.win:time_batch(15 sec) having count(*) > 0",
        :message => "Generated from statement: <%= statement[:name] %>. Found <%= match['count'] %> number of events in 15 seconds.",
      }
      esper.create_statement(statement)

      statement = {
        :name => "count_every_15_seconds_with_foo",
        :expression => "select count(*) as count from event.win:time_batch(15 sec) where message = 'foo'",
        :message => "Generated from statement: <%= statement[:name] %>. Found <%= match['count'] %> number of events in 15 seconds that match 'foo'.",
      }
      esper.create_statement(statement)

      # Subscribe to inbound MQ events
      mq.subscribe
    end
  end
end
