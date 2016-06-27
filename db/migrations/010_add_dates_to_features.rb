Sequel.migration do
  change do
    alter_table(:features) do
      add_column :start_timeslot, DateTime, { default: nil }
      add_column :end_timeslot, DateTime, { default: nil }
    end
  end
end
