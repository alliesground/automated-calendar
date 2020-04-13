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
      stub_access_to_google_calendar
    end
  end

  describe 'before_destroy' do
    context 'when user has authorized access to their google calendar' do
      include_context 'allow access to google calendar'

      it 'calls GoogleEventDestroyer worker with correct args' do
        google_event.destroy

        expect(GoogleEventDestroyer).to have_enqueued_sidekiq_job(
          user.id,
          google_calendar.remote_id,
          google_event.remote_id
        )
      end
    end
  end

  describe 'after_create_commit' do
    context 'when user has authorized access to their google calendar' do
      include_context 'allow access to google calendar'

      it 'calls GoogleEventCreator worker with correct args' do
        expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
          google_event.id
        )
      end
    end
  end
end
