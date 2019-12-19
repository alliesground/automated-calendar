class EventPresenter
  attr_reader :event

  delegate_missing_to :event

  def initialize(event)
    @event = event
  end

  def start_time
    event.start_time.strftime("%c")
  end

  def end_time
    event.end_time.strftime("%c")
  end

  def event_start_date
    event.start_time&.strftime('%b %d, %Y')
  end

  def event_end_date
    event.end_time&.strftime('%b %d, %Y')
  end

  def event_start_time
    event.start_time&.strftime('%I:%M %p' )
  end

  def event_end_time
    event.end_time&.strftime('%I:%M %p' )
  end
end
