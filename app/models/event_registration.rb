class EventRegistration
  include ActiveModel::Model

  delegate :id, :title, :persisted?, to: :event 
  delegate :event_start_date, 
           :event_end_date, 
           :event_start_time, 
           :event_end_time, to: :event_presenter

  validate :validate_children

  attr_writer :event

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Event')
  end

  def event_presenter
    EventPresenter.new(event)
  end

  def event
    @event ||= Event.new
  end

  def save(params)
    event.attributes = event_params(params)

    if valid?
      if event.save
        #event.create_google_event(params[:google_calendar_id])
      end
      true
    else
      false
    end
  end

  def update(params)
    event.attributes = event_params(params)

    if valid?
      if event.save
#        GoogleEventUpdater.perform_async(
#          params[:google_calendar_id], 
#          event.id
#        )
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
                 :event_end_time, 
                 :user_id)
  end

  def validate_children
    if event.invalid?
      event.errors.each do |key, val|
        errors.add(key, val)
      end
    end
  end
end
