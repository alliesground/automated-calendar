class EventRegistration
  include ActiveModel::Model

  delegate :id, 
           :title, 
           :persisted?, to: :event

  #delegate :google_calendar_id, to: :google_event

  validate :validate_children
  validates_presence_of :event_start_date,
                        :event_end_date,
                        :event_start_time,
                        :event_end_time,
                        :google_calendar_id

  attr_accessor :event_start_date,
                :event_end_date,
                :event_start_time,
                :event_end_time,
                :google_calendar_id

  def event_start_date
    @event_start_date || event_presenter.event_start_date
  end

  def event_end_date
    @event_end_date || event_presenter.event_end_date
  end

  def event_start_time
    @event_start_time || event_presenter.event_start_time
  end

  def event_end_time
    @event_end_time || event_presenter.event_end_time
  end

  attr_reader :registrar

  def initialize(registrar:, event: nil)
    @registrar = registrar
    @event = event
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Event')
  end

  def event_presenter
    EventPresenter.new(event)
  end

  def event
    @event ||= registrar.events.build
  end

  def google_event
    @google_event ||= (event.google_event || event.build_google_event)
  end

  def set_start_time
    date = Time.zone.parse(event_start_date)
    time = Time.zone.parse(event_start_time)
    Time.zone.parse("#{date.strftime('%F')} #{time.strftime('%T')}")
  end

  def set_end_time
    date = Time.zone.parse(event_end_date)
    time = Time.zone.parse(event_end_time)
    Time.zone.parse("#{date.strftime('%F')} #{time.strftime('%T')}")
  end

  def save_event
    event.attributes = {
      start_time: set_start_time,
      end_time: set_end_time
    }

    event.save
  end

  def google_calendar
    @google_calendar ||= GoogleCalendar.find_by(id: google_calendar_id)
  end

  def save(params)
    self.attributes = event_registration_params(params)
    event.attributes = params.slice(:title)
    google_event.attributes = params.slice(:google_calendar_id)

    if valid?
      save_event
      google_event.save

      GoogleCalendarEventCreator.perform_async(
        event.id,
        params[:google_calendar_id],
        registrar.id
      )

      registrar.outbound_event_configs.each do |outbound_event_config|
        if outbound_event_config.configured_for?(params[:google_calendar_id])

          if google_calendar_exists_for?(outbound_event_config.receiver)
            GoogleCalendarEventCreator.perform_async(
              event.id, 
              google_calendar_for(outbound_event_config.receiver).remote_id,
              outbound_event_config.receiver_id
            )
          else
            GoogleCalendarCreator.perform_async(
              google_calendar_for(outbound_event_config.receiver).id,
              google_calendar_for(outbound_event_config.receiver).name,
              outbound_event_config.receiver_id
            )

            GoogleCalendarEventCreator.perform_async(
              event.id, 
              google_calendar_for(outbound_event_config.receiver).remote_id,
              outbound_event_config.receiver_id
            )
          end
        end
      end

      true
    else
      false
    end
  end

  def google_calendar_exists_for?(receiver)
    receiver.google_calendars.
      where("lower(name) = ?", google_calendar.name.downcase).
      exists?
  end

  def google_calendar_for(receiver)
    receiver.
    google_calendars.
    where("lower(name) = ?", google_calendar.name.downcase).
    first_or_create
  end

  def update(params)
    self.attributes = event_registration_params(params)
    event.attributes = params.slice(:title)
    google_event.attributes = params.slice(:google_calendar_id)

    if valid?
      save_event
      google_event.save
      true
    else
      false
    end
  end

  private

  def event_registration_params(params)
    params.slice(:event_start_date, 
                 :event_end_date, 
                 :event_start_time, 
                 :event_end_time,
                 :google_calendar_id)
  end

  def validate_children
    if event.invalid?
      event.errors.each do |key, val|
        errors.add(key, val)
      end
    end
  end
end
