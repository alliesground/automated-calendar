class OutboundEventProcessing
  attr_accessor :outbound_event_config,
                :receiver,
                :event,
                :current_google_calendar

  def initialize(outbound_event_config, current_google_calendar, event, previous_event: nil)
    @outbound_event_config = outbound_event_config
    @receiver = outbound_event_config.receiver
    @event = event
    @current_google_calendar = current_google_calendar
    @previous_event = previous_event
  end

  def start

    if(outbound_event_config.configured_for?(current_google_calendar) &&
       GoogleCalendarConfig.authorized_by?(receiver))

      if receiver.google_calendars.exist_with_name?(current_google_calendar.name)
        GoogleEventCreator.perform_async(
          event.id, 
          receiver_google_calendar.id,
          receiver.id
        )
      else
        receiver.google_calendars.create(
          name: current_google_calendar.name
        )

        batch = Sidekiq::Batch.new

        batch.on(:success,
                 OutboundEventProcessing::CalendarCreationCallback,
                 'google_calendar_id' => receiver_google_calendar.id, 
                 'receiver_id' => receiver.id, 
                 'event_id' => event.id)

        batch.jobs do
          GoogleCalendarCreator.perform_async(
            receiver_google_calendar.id,
            receiver_google_calendar.name,
            receiver.id
          )
        end
      end
    end
  end

  def update
    if(outbound_event_config.configured_for?(current_google_calendar) &&
       GoogleCalendarConfig.authorized_by?(receiver))

      if receiver.google_calendars.exist_with_name?(current_google_calendar.name)

        event.google_events_for(receiver).each do |google_event|
          GoogleEventUpdater.perform_async(
            event.id,
            receiver_google_calendar.remote_id,
            google_event.remote_id,
            receiver.id
          )
        end

      end
    end
  end

  class CalendarCreationCallback
    def on_success(_status, options)
      google_calendar = GoogleCalendar.find_by(id: options['google_calendar_id'])

      GoogleEventCreator.perform_async(
        options['event_id'], 
        google_calendar.id,
        options['receiver_id']
      )
    end
  end

  private

  def receiver_google_calendar
    receiver.google_calendars.find_by_lowercase_name(current_google_calendar.name).first
  end

end
