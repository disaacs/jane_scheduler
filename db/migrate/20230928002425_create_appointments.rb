class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.datetime :starts_at, null: false
      t.string :type, null: false
      t.string :patient_name, null: false

      t.timestamps
    end
  end
end
