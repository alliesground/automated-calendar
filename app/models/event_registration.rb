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

  attr_reader :registrant

  def initialize(registrant:, event: nil)
    @registrant = registrant
    @event = event
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Event')
  end

  def event_presenter
    EventPresenter.new(event)
  end

  def event
    @event ||= registrant.events.build
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

      GoogleEventCreator.perform_async(
        event.id,
        google_calendar.remote_id,
        registrant.id
      )

      registrant.outbound_event_configs.each do |outbound_event_config|

        OutboundEventProcessing.new(
          outbound_event_config, 
          google_calendar,
          event
        ).start
      end

      true
    else
      false
    end
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
