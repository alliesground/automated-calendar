require 'rails_helper'

RSpec.describe GoogleEvent, type: :model do
  let(:user) { create(:user) }
  let(:event) { create(:event, user: user) }
  let(:google_calendar) { create(:google_calendar, user: user) }
  let(:google_event) { 
    create(:google_event, event: event, google_calendar: google_calendar) 
  }

  shared_context 'allow access to google calendar' do
    before do
      allow(GoogleCalendarConfig).to receive(:authorized_by?).with(any_args).and_return(true)
    end
  end

  shared_context 'destroy' do
    before {google_event.destroy}
  end
  
  context 'before destroy' do
    describe '#destroy_remote_google_event' do
      context 'when user has authorized access to their google calendar' do
        include_context 'allow access to google calendar'
        include_context 'destroy'

        it 'calls GoogleEventDestroyer worker with correct args' do

          expect(GoogleEventDestroyer).to have_enqueued_sidekiq_job(
            user.id,
            google_calendar.remote_id,
            google_event.remote_id
          )
        end
      end
    end
  end
end
