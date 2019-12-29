class EventRegistrationsController < ApplicationController
  before_action :set_event, only: [:edit, :update]

  def new
    @event_registration = EventRegistration.new
  end

  def create
    @event_registration = EventRegistration.new

    respond_to do |format|
      if @event_registration.save(event_registration_params.merge(user_id: current_user.id))
        format.js do
          flash[:notice] = 'Event saved'
          redirect_to events_path
        end
      else
        format.js do
          set_message('Please fill up the required fields')

          render partial: 'form_errors',
          status: 400
        end
      end
    end
  end

  def edit
    @event_registration = EventRegistration.new(event: @event)
  end

  def update
    @event_registration = EventRegistration.new(event: @event) 

    respond_to do |format|
      if @event_registration.update(event_registration_params)
        format.js do
          flash[:notice] = 'Event updated successfully'
          redirect_to events_path
        end
      else
        format.js do
          set_message('Please fill the required fields')
          render partial: 'form_errors', 
                 status: 400

        end
      end
    end
  end

  private

  def set_event
    @event = current_user.events.find_by(id: params[:id])
  end

  def set_message(msg)
    response.set_header('Message', msg)
  end

  def event_registration_params 
    params.require(:event_registration).permit(
      :title,
      :event_start_date,
      :event_start_time,
      :event_end_date,
      :event_end_time
    )
  end

end
