class OutboundEventConfigsController < ApplicationController
  def new
    @outbound_event_config_form = OutboundEventConfigForm.new
  end

  def create
    @outbound_event_config_form = OutboundEventConfigForm.new(outbound_event_config_params, user: current_user)

    @outbound_event_config_form.save
  end

  private

  def outbound_event_config_params
    params.require(:outbound_event_config).permit(
      :google_calendar_id, receiver_ids: [])
  end
end
