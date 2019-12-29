class EventRegistration
  include ActiveModel::Model

  delegate :id, :title, to: :event 
  delegate :event_start_date, 
           :event_end_date, 
           :event_start_time, 
           :event_end_time, to: :event_presenter

  validate :validate_children

  attr_writer :event

#  def initialize(attributes={})
#    super
#
#    if user.present?
#      @event ||= user.events.build(
#        attributes.slice(:title, 
#                         :event_start_date,
#                         :event_end_date,
#                         :event_start_time,
#                         :event_end_time)
#      )
#    end
#  end

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Event')
  end

  def event_presenter
    EventPresenter.new(event)
  end

  def event
    @event ||= Event.new
  end

  def persisted?
    event.persisted?
  end

  def save(params)
    event.attributes = event_params(params)

    if valid?
      event.save
      true
    else
      false
    end
  end

  def update(params)
    event.attributes = event_params(params)

    if valid?
      event.save
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
