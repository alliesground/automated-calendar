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
end
