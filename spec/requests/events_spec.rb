require 'rails_helper'

RSpec.describe 'Event', type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe 'event deletion' do
    let!(:event) { create(:event, user: user) }
    before do
      create(:google_event, event: event)
    end

    it 'destroys an event' do
      expect {
        delete event_path event
      }.to change(Event, :count).by -1
    end

    it 'deletes associated google_events' do
      expect {
        delete event_path event
      }.to change(GoogleEvent, :count).by -1
      
    end
  end
end
