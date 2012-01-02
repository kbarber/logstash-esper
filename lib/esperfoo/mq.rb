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
        #puts data.inspect
        payload = JSON.parse(data[:payload])
        puts payload.inspect
        ep_runtime.sendEvent(payload, "event")
      end
    end

    def publish(message)
      @out_exchange.publish(message, :persistent => true, :key => "esperfooin", :mandatory => true)
    end
  end
end
