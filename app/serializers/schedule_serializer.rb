class ScheduleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :is_done, :start_at, :end_at
  belongs_to :job
end
