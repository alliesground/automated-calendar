class OutboundEventConfigFormsController < ApplicationController
  def new
    @outbound_event_config_form = OutboundEventConfigForm.new
  end
end
