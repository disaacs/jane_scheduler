class Appointment < ApplicationRecord
  self.inheritance_column = nil

  APPOINTMENT_TYPE = {
    initial:  'initial',
    standard: 'standard',
    checkin:  'checking'
  }

  APPOINTMENT_LENGTH = {
    initial:  90.minutes,
    standard: 60.minutes,
    checkin:  30.minutes
  }

  validates :starts_at, :type, :patient_name, presence: true
  validates :type, inclusion: { in: APPOINTMENT_TYPE.values, message: 'is unrecognized' }
  validate :starts_at_is_ok, on: :create

  class << self
    def schedule(date)
      Appointment.where('starts_at >= ? and starts_at < ?', date, date.tomorrow)
    end

    def scheduled_slots(date)
      schedule(date).map(&:time_slots).flatten
    end
  end

  def time_slots
    starting_slot = starts_at.hour - 9
    ending_slot = starting_slot + appointment_length/30.minutes - 1
    (starting_slot..ending_slot).to_a
  end

  def appointment_length
    APPOINTMENT_LENGTH[type.to_sym] || 0
  end

  def starts_at_is_ok
    does_not_overlap
    during_business_hours
    not_too_soon
    on_the_hour_or_half_hour
  end

  def does_not_overlap
    if (Appointment.scheduled_slots(starts_at.to_date) & time_slots).present? 
      errors.add(:starts_at, 'conflicts with an existing appointment')
    end
  end

  def during_business_hours
    if starts_at.hour < 9
      errors.add(:starts_at, 'is before 9 AM')
    elsif (starts_at + appointment_length).hour >= 17
      errors.add(:starts_at, 'is too late in the day for the type of appointment')
    end
  end

  def not_too_soon
    if starts_at < Time.now.utc + 2.hours
      errors.add(:starts_at, 'must be more than 2 hours from now')
    end
  end

  def on_the_hour_or_half_hour
    if [0,30].exclude? starts_at.min
      errors.add(:starts_at, 'must be on the hour or half-hour')
    end
  end

  
end
