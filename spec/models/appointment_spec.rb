require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'Creating an appointment' do

    context 'Everything is correct' do
      it 'successfully creates the appointment' do
        travel_to Time.parse('2023-09-29 09:00 UTC') do
          appointment = Appointment.new(starts_at: Time.now.utc+3.hours, type: :initial, patient_name: 'Alice')
          expect { appointment.save }.to change { Appointment.count }.by(1)
        end
      end
    end

    context 'Invalid start times' do
      it 'fails to validate appointment before 9 AM' do
        travel_to Time.parse('2023-09-29 09:00 UTC') do
          appointment = Appointment.new(starts_at: Date.tomorrow+8.hours, type: :initial, patient_name: 'Alice')
          expect { appointment.save }.to change { Appointment.count }.by(0)
          expect(appointment.errors.full_messages.first).to eq('Starts at is before 9 AM')
        end
      end

      it 'fails to validate appointments running past 5 PM' do
        travel_to Time.parse('2023-09-29 09:00 UTC') do
          appointment = Appointment.new(starts_at: Date.tomorrow+16.hours, type: :initial, patient_name: 'Alice')
          expect { appointment.save }.to change { Appointment.count }.by(0)
          expect(appointment.errors.full_messages.first).to eq('Starts at is too late in the day for the type of appointment')
        end
      end

      it 'fails to validate appointments less than 2 hours in the future' do
        travel_to Time.parse('2023-09-29 09:00 UTC') do
          appointment = Appointment.new(starts_at: Date.today+10.hours, type: :initial, patient_name: 'Alice')
          expect { appointment.save }.to change { Appointment.count }.by(0)
          expect(appointment.errors.full_messages.first).to eq('Starts at must be more than 2 hours from now')
        end
      end

      it 'fails to validate appointments not starting on the hour or the half-hour' do
        travel_to Time.parse('2023-09-29 09:00 UTC') do
          appointment = Appointment.new(starts_at: Date.tomorrow+9.hours+17.minutes, type: :initial, patient_name: 'Alice')
          expect { appointment.save }.to change { Appointment.count }.by(0)
          expect(appointment.errors.full_messages.first).to eq('Starts at must be on the hour or half-hour')
        end
      end

      it 'fails to validate appointment that overlaps other appointment' do
        travel_to Time.parse('2023-09-29 09:00 UTC') do
          Appointment.create(starts_at: Time.now.utc+5.hours, type: :initial, patient_name: 'Alice')
          appointment = Appointment.new(starts_at: Time.now.utc+4.hours, type: :initial, patient_name: 'Bob')
          expect { appointment.save }.to change { Appointment.count }.by(0)
          expect(appointment.errors.full_messages.first).to eq('Starts at conflicts with an existing appointment')
        end
      end

      it 'fails to validate appointment that starts during other appointment' do
        travel_to Time.parse('2023-09-29 09:00 UTC') do
          Appointment.create(starts_at: Time.now.utc+4.hours, type: :initial, patient_name: 'Alice')
          appointment = Appointment.new(starts_at: Time.now.utc+5.hours, type: :initial, patient_name: 'Bob')
          expect { appointment.save }.to change { Appointment.count }.by(0)
          expect(appointment.errors.full_messages.first).to eq('Starts at conflicts with an existing appointment')
        end
      end      
    end
  end
end
