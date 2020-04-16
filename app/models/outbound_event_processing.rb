class OutboundEventProcessing
  attr_accessor :outbound_event_config,
                :event,
                :receiver,
                :current_google_calendar

  def initialize(outbound_event_config, event)
    @outbound_event_config = outbound_event_config
    @event = event
    @receiver = outbound_event_config.receiver
    @current_google_calendar = outbound_event_config.google_calendar
  end

  def self.execute(*args)
    new(*args).execute
  end

  def execute
    return unless GoogleCalendarConfig.authorized_by?(receiver)

    unless receiver.has_google_calendar_with_name?(current_google_calendar.name)
      create_google_calendar
      return
    end

    google_event = event.
                   google_events.
                   by_user(receiver).
                   by_calendar_name(current_google_calendar.name).
                   first


    if google_event.present?
      GoogleEventUpdater.perform_async(
        event.id,
        receiver_google_calendar.remote_id,
        google_event.remote_id,
        receiver.id
      )
    else
      event.google_events.create(
        google_calendar_id: receiver_google_calendar.id
      )
    end
  end

  class CalendarCreationCallback
    def on_success(_status, options)
      google_calendar = GoogleCalendar.find_by(id: options['google_calendar_id'])

      event = Event.find_by(id: options['event_id'])

      event.google_events.create(google_calendar_id: google_calendar.id)
    end
  end

  private

  def receiver_google_calendar
    receiver.google_calendars.by_lowercase_name(current_google_calendar.name).first
  end

  def create_google_calendar
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
