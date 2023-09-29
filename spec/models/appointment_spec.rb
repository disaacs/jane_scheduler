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

      it 'successfully creates back-to-back appointments of different types' do
        travel_to Time.parse('2023-09-29 00:00 UTC') do
          expect {
            Appointment.create(starts_at: Time.now.utc+9.hours, type: :initial, patient_name: 'Alice')
            Appointment.create(starts_at: Time.now.utc+10.5.hours, type: :standard, patient_name: 'Bob')
            Appointment.create(starts_at: Time.now.utc+11.5.hours, type: :checkin, patient_name: 'Carol')
            Appointment.create(starts_at: Time.now.utc+12.hours, type: :initial, patient_name: 'Darryl')
          }.to change { Appointment.count }.by(4)
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

  describe 'ends_at attribute' do
    it 'is 90 minutes after starts_at for an initial appointment' do
      travel_to Time.parse('2023-09-29 09:00 UTC') do
        appointment = Appointment.create(starts_at: Time.now.utc, type: :initial, patient_name: 'Alice')
        expect(appointment.ends_at - appointment.starts_at).to eq(90.minutes)
      end
    end

    it 'is 60 minutes after starts_at for a standard appointment' do
      travel_to Time.parse('2023-09-29 09:00 UTC') do
        appointment = Appointment.create(starts_at: Time.now.utc, type: :standard, patient_name: 'Alice')
        expect(appointment.ends_at - appointment.starts_at).to eq(60.minutes)
      end
    end

    it 'is 30 minutes after starts_at for an checkin appointment' do
      travel_to Time.parse('2023-09-29 09:00 UTC') do
        appointment = Appointment.create(starts_at: Time.now.utc, type: :checkin, patient_name: 'Alice')
        expect(appointment.ends_at - appointment.starts_at).to eq(30.minutes)
      end
    end
  end
end
