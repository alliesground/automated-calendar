class EventRegistration
  include ActiveModel::Model

  delegate :id, 
           :title, 
           :persisted?, to: :event

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
    @event_presenter ||= EventPresenter.new(event)
  end

  def event
    @event ||= registrant.events.build
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

  def google_calendar_id
    @google_calendar_id ||= event.
                            google_events.
                            by_user(registrant).
                            first&.google_calendar_id
  end

  def save(params)
    self.attributes = event_registration_params(params)
    event.attributes = params.slice(:title)

    if valid?
      save_event

      registrant.outbound_event_configs_for(google_calendar)
        .each do |outbound_event_config|

        OutboundEventProcessing.execute(
          outbound_event_config,
          event
        )
      end

      return unless GoogleCalendarConfig.authorized_by?(registrant)

      google_events.create(google_calendar_id: google_calendar.id)

      true
    else
      false
    end
  end

  def update(params)
    params.merge!(google_calendar_id: params[:google_calendar_id].to_i)
    self.attributes = event_registration_params(params)
    event.attributes = params.slice(:title)

    if valid?
      save_event

      registrant.outbound_event_configs_for(google_calendar)
        .each do |outbound_event_config|

        OutboundEventProcessing.execute(
          outbound_event_config,
          event
        )
      end

      if calendar_changed?
        destroy_all_google_events_with_previous_calendar_name
      end

      return unless GoogleCalendarConfig.authorized_by?(registrant)

      google_event = event.
                     google_events.
                     by_user(registrant).
                     by_calendar_name(google_calendar.name).
                     first

      if google_event.present?
        GoogleEventUpdater.perform_async(
          event.id,
          google_calendar.remote_id,
          google_event.remote_id,
          registrant.id
        )
      else
        event.google_events.create(
          google_calendar_id: google_calendar.id
        )
      end

      true
    else
      false
    end
  end

  private

  def destroy_all_google_events_with_previous_calendar_name
    google_events.by_calendar_name(previous_calendar.name).each do |google_event|

      next unless GoogleCalendarConfig.authorized_by?(google_event.user)

      google_event.destroy
    end 
  end

  def google_events 
    event.google_events
  end

  def previous_calendar
    google_events.by_user(registrant)
    event.google_events_for(registrant).first.google_calendar
  end

  def calendar_changed?
    event.google_events_for(registrant).first.google_calendar_id != google_calendar_id
  end

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
