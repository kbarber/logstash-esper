require 'jars/esper-4.4.0.jar'
require 'jars/commons-logging-1.1.1.jar'
require 'jars/antlr-runtime-3.2.jar'
require 'jars/cglib-nodep-2.2.jar'
require 'esperfoo/listeners'

module EsperFoo
  class Statement
    def initialize(statement, mq)
      ep_service = com.espertech.esper.client.EPServiceProviderManager.getDefaultProvider
      ep_administrator = ep_service.getEPAdministrator
      ep_statement = ep_administrator.createEPL(statement[:expression])
      listener = EsperFoo::Listener.new(statement, mq)
      ep_statement.addListener(listener)
    end
  end
end
