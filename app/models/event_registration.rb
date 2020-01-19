class EventRegistration
  include ActiveModel::Model

  delegate :id, 
           :title, 
           :persisted?, to: :event 

  delegate :event_start_date, 
           :event_end_date, 
           :event_start_time, 
           :event_end_time, to: :event_presenter

  delegate :google_calendar_id, to: :google_event

  validate :validate_children
  validates_presence_of :google_calendar_id

  attr_writer :event
  attr_reader :registrar

  def initialize(registrar:, **attributes)
    super(attributes)
    @registrar = registrar
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

  def save(params)
    event.attributes = event_params(params)
    google_event.attributes = { google_calendar_id: params[:google_calendar_id] }

    if valid?
      event.save
      google_event.save

      GoogleCalendarEventCreator.perform_async(event.id, params[:google_calendar_id], registrar.id)

      true
    else
      false
    end
  end

  def update(params)
    event.attributes = event_params(params)

    if valid?
      if event.save
        google_event.update(google_calendar_id: params[:google_calendar_id])
      end
      true
    else
      false
    end
  end

  private

  def event_params(params)
    params.slice(:title, 
                 :event_start_date, 
                 :event_end_date, 
                 :event_start_time, 
                 :event_end_time)
  end

  def validate_children
    if event.invalid?
      event.errors.each do |key, val|
        errors.add(key, val)
      end
    end
  end
end
