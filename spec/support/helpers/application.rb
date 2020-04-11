module Helpers 
  module Application
    def stub_access_to_google_calendar
      allow(GoogleCalendarConfig).to receive(:authorized_by?).with(any_args).and_return(true)
    end
  end
end
