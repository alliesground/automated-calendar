class OutboundEventConfigsController < ApplicationController
  def new; end

  def create
    @outbound_event_config_form = OutboundEventConfigForm.new(outbound_event_config_params, user: current_user)

    respond_to do |format|
      if @outbound_event_config_form.save
        format.js do
          flash.now[:notice] = 'configuration saved'
          #redirect_to events_path
        end
      else
        format.js do
          set_message('Please fill up the required fields')

          render partial: 'form_errors', 
                 locals: {obj: @outbound_event_config_form},
                 status: 400
        end
      end
    end
  end

  private

  def set_message(msg)
    response.set_header('Message', msg)
  end

  def outbound_event_config_params
    params.require(:outbound_event_config).permit(
      :google_calendar_id, receiver_ids: [])
  end
end
