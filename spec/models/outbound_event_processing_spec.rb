require 'rails_helper'

RSpec.describe OutboundEventProcessing, type: :model do
  describe '#start' do
#    context 'when registrant has configured receiver to receive the event on the current calendar' do
#
#      before do
#        create(:outbound_event_config, 
#               owner: registrant, 
#               receiver: receiver, 
#               google_calendar: registrant_google_calendar )
#
#      end
#
#      context 'if the receiver has a calendar with name similar to current calendar' do
#
#        let!(:receiver_google_calendar) { create(:google_calendar, user: receiver) }
#
#        it "executes GoogleEventCreator worker" do
#          event_registration.save(params)
#
#          expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
#            Event.last.id,
#            receiver_google_calendar.remote_id,
#            receiver.id
#          )
#        end
#      end
#
#      context 'if the receiver does not have a calendar with name similar to current calendar' do
#        it 'creates google calendar locally' do
#          expect{event_registration.save(params)}.to change{GoogleCalendar.count}.by(1)
#        end
#
#        it 'enques GoogleCalendarCreator worker job' do
#          event_registration.save(params)
#          receiver_google_calendar = GoogleCalendar.last
#
#          expect(GoogleCalendarCreator).to have_enqueued_sidekiq_job(
#            receiver_google_calendar.id,
#            receiver_google_calendar.name,
#            receiver.id
#          )
#        end
#
#        it 'enques GoogleEventCreator worker job with remote calendar id' do
#          event_registration.save(params)
#
#          receiver_google_calendar = GoogleCalendar.last
#
#          # stubing update by GoogleCalendarCreator worker
#          receiver_google_calendar.update(remote_id: '123')
#
#          OutboundEventProcessing.new
#
#          b = Sidekiq::Batch.new
#          b.on(:success,
#               "OutboundEventProcessing#execute_google_event_creator_worker",
#               receiver: receiver)
#
#          outbound_event_processing.execute_google_event_creator_worker(
#            Sidekiq::Batch::Status.new(b.bid), 
#            {receiver: receiver}
#          )
#
#          expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
#            Event.last.id,
#            receiver_google_calendar.remote_id,
#            receiver.id
#          )
#
#          expect(GoogleEventCreator.jobs.last['args'][1]).not_to be_nil
#        end
#      end
#
#    end
  end
end
