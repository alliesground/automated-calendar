class OutboundEventConfigsController < ApplicationController
  def new
    @outbound_event_configs_form = OutboundEventConfigsForm.new
  end

  def create
    @outbound_event_configs_form = OutboundEventConfigsForm.new(outbound_event_configs_form_params, user: current_user)

    respond_to do |format|
      if @outbound_event_configs_form.save
        format.js do
          set_message('Configuration saved successfully')
        end
      else
        format.js do
          set_message('Please fill up the required fields')

          render partial: 'form_errors', 
                 locals: {obj: @outbound_event_configs_form},
                 status: 400
        end
      end
    end
  end

  private

  def set_message(msg)
    response.set_header('Message', msg)
  end

  def outbound_event_configs_form_params
    params.require(:outbound_event_configs_form).permit(
      :google_calendar_id, outbound_event_configs_attributes: [:receiver_id])
  end
end
