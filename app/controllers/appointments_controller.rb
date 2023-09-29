class AppointmentsController < ApplicationController
  def index
    available_appointments = []
    appointment = Appointment.new(type: params[:type], patient_name: 'Valuable Customer')
    date = Date.parse(params[:date])
    (9..16.5).step(0.5).each do |start_time|
      appointment.starts_at = date+start_time.hours
      available_appointments << appointment.dup if appointment.valid?
    end
    render json: available_appointments.as_json(only: [:starts_at, :ends_at, :type]), status: :ok
  end

  def create
    appointment = Appointment.new(appointment_params)
    if appointment.save
      render json: appointment, status: :created
    else
      render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def schedule
    date = Date.parse(params[:date])
    appointments = Appointment.where(starts_at: date.beginning_of_day..date.end_of_day)
    render json: appointments, status: :ok
  rescue Date::Error
    render json: { errors: ['Invalid date'] }, status: :unprocessable_entity
  end

  private

  def appointment_params
    params.require(:appointment).permit(:starts_at, :type, :patient_name)
  end
end
