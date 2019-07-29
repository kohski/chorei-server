class JobSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :description, :image, :is_public, :frequency, :repeat_times, :base_start_at, :base_end_at
end
