require 'java'
require 'jars/esper-4.4.0.jar'
require 'jars/commons-logging-1.1.1.jar'
require 'jars/antlr-runtime-3.2.jar'
require 'jars/cglib-nodep-2.2.jar'
require 'bunny'
require 'json'
require 'erb'

module EsperFoo
  # Create a listener object
  class Listener
    include com.espertech.esper.client.UpdateListener

    def initialize(statement, mq)
      @statement = statement
      @mq = mq
    end

    def update(newEvents, oldEvents)
      if newEvents then
        puts "newEvents matched: "
        newEvents.each do |event|
          if event.class == com.espertech.esper.event.WrapperEventBean then
            puts "Wrapped events are not allowed"
          else
            # Grab the match event
            match = event.getUnderlying.to_hash

            # Grab the statement so it isn't a instance var
            statement = @statement

            # Parse the statement message as ERB
            message_erb = ERB.new(@statement[:message])
            message = message_erb.result(binding)

            new_event = {
              "@source"      => "esper://kb.local",
              "@type"        => "correlated",
              "@tags"        => [],
              "@fields"      => match,
              "@timestamp"   => "2011-12-31T04:27:33.279000Z",
              "@source_host" => "kb.local",
              "@source_path" => "/",
              "@message"     => message,
            }
            puts "- " + new_event.to_json

            @mq.publish(new_event.to_json)
          end
        end
      end

      if oldEvents then
        puts "oldEvents matched: "
        oldEvents.each do |event|
          puts "-(type:#{event.class}) " + event.getUnderlying.inspect
        end
      end
    end
  end

  # Create an unmatched listener
  class UnmatchedListener
    include com.espertech.esper.client.UnmatchedListener

    def update(event)
      puts "unmatched:\n- " + event.getUnderlying.inspect
    end
  end
end
