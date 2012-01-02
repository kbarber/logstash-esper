require 'java'
require 'jars/esper-4.4.0.jar'
require 'jars/commons-logging-1.1.1.jar'
require 'jars/antlr-runtime-3.2.jar'
require 'jars/cglib-nodep-2.2.jar'
require 'bunny'
require 'json'

module EsperFoo
  class Mq
    def initialize
      # These settings should be gleaned from a configuration file
      amqpsettings = {
        :vhost    => "/",
        :host     => "192.168.182.156",
        :port     => "5672",
        :user     => "guest",
        :password => "guest",
      }

      @bunny = Bunny.new(amqpsettings)

      @bunny.start
      @bunny.qos({:prefetch_count => 1})

      # TODO: all of this queue detail should be obtained from configuration
      @in_exchange = @bunny.exchange("esperfoo", :type => :fanout.to_sym, :durable => true)
      @in_queue = @bunny.queue("esperfoo", {:durable => true})
      @in_queue.bind(@exchange, :key => "esperfoo")

      @out_exchange = @bunny.exchange("esperfooin", :type => :fanout.to_sym, :durable => true)
      @out_queue = @bunny.queue("esperfooin", {:durable => true})
      @out_queue.bind(@exchange, :key => "esperfooin")
    end

    def subscribe
      ep_service = com.espertech.esper.client.EPServiceProviderManager.getDefaultProvider
      ep_runtime = ep_service.getEPRuntime

      @in_queue.subscribe({:ack => true}) do |data|
        payload = JSON.parse(data[:payload])

        # TODO: this should be output through a debug channel
        puts payload.inspect

        # Post the received event through the Esper engine
        ep_runtime.sendEvent(payload, "event")
      end
    end

    # Publish message back to a queue
    def publish(message)
      # TODO: queue name and configuration should be in a config file
      @out_exchange.publish(message, :persistent => true, :key => "esperfooin", :mandatory => true)
    end
  end
end
