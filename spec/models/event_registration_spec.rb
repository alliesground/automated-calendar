require 'rails_helper'

RSpec.describe EventRegistration, type: :model do
  describe '#save' do
    let(:registrar) { create(:user) }
    let(:event_registration) { EventRegistration.new(registrar: registrar) }
    let(:registrar_google_calendar) { create(:google_calendar, user: registrar, remote_id: 'ABC') }
    let(:receiver) { create(:user, email: 'test2@email.com') }

    let(:params) do
      {
        title: 'test event',
        event_start_date: 'Fed 03, 2020',
        event_end_date: 'Fed 03, 2020',
        event_start_time: '01:00 PM',
        event_end_time: '02:00 PM',
        google_calendar_id: registrar_google_calendar.id
      }
    end

    context 'when registrar has configured receiver to receive the event on the current calendar' do

      before do
        create(:outbound_event_config, 
               owner: registrar, 
               receiver: receiver, 
               google_calendar: registrar_google_calendar )

      end

      context 'if the receiver has a calendar with name similar to current calendar' do

        let!(:receiver_google_calendar) { create(:google_calendar, user: receiver) }

        it "executes GoogleEventCreator worker" do
          event_registration.save(params)

          expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
            Event.last.id,
            receiver_google_calendar.remote_id,
            receiver.id
          )
        end
      end

      context 'if the receiver does not have a calendar with name similar to current calendar' do
        it 'creates google calendar locally' do
          expect{event_registration.save(params)}.to change{GoogleCalendar.count}.by(1)
        end

        it 'enques GoogleCalendarCreator worker job' do
          event_registration.save(params)
          receiver_google_calendar = GoogleCalendar.last

          expect(GoogleCalendarCreator).to have_enqueued_sidekiq_job(
            receiver_google_calendar.id,
            receiver_google_calendar.name,
            receiver.id
          )
        end

        it 'enques GoogleEventCreator worker job with remote calendar id' do
          event_registration.save(params)
          receiver_google_calendar = GoogleCalendar.last

          receiver_google_calendar.update(remote_id: '123')

          b = Sidekiq::Batch.new

          event_registration.execute_google_event_creator(Sidekiq::Batch::Status.new(b.bid), {receiver: receiver})


          expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
            Event.last.id,
            receiver_google_calendar.remote_id,
            receiver.id
          )

          expect(GoogleEventCreator.jobs.last['args'][1]).not_to be_nil
        end
      end

    end
  end
end
