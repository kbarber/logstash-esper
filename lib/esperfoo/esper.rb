require 'java'
require 'jars/esper-4.4.0.jar'
require 'jars/commons-logging-1.1.1.jar'
require 'jars/antlr-runtime-3.2.jar'
require 'jars/cglib-nodep-2.2.jar'
require 'esperfoo/listeners'

module EsperFoo
  class Esper
    def initialize(mq)
      @mq = mq

      @ep_service = com.espertech.esper.client.EPServiceProviderManager.getDefaultProvider
      @ep_runtime = @ep_service.getEPRuntime
      @ep_administrator = @ep_service.getEPAdministrator
      @ep_config = @ep_administrator.getConfiguration

      # Add logstash event type
      @ep_config.addEventType("event", {
        "@source"      => "string",
        "@type"        => "string",
        "@tags"        => "string",
        "@fields"      => {},
        "@timestamp"   => "string",
        "@source_host" => "string",
        "@source_path" => "string",
        "@message"     => "string",
      })

      # Register unmatched listener
      unmatched_listener = EsperFoo::UnmatchedListener.new
      @ep_runtime.setUnmatchedListener(unmatched_listener)
    end

    def create_statement(statement)
      EsperFoo::Statement.new(statement, @mq)
    end
  end
end
