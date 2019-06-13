FactoryBot.define do
  factory :step do
    job_id { Job.first ? Job.first.id : create(:job).id }
    sequence(:memo){|n| "test title #{n}" }
    image { 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAAAAAAeW/F+AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAAmJLR0QA/4ePzL8AAAAHdElNRQfjBRQABBrSkbBKAAAAT0lEQVQoz2M4gxcwjEoPkPSmjau3rNoEFULmQKSPr18/59icM2e27d2J4MClTx05Mn8+SOTUIiQOQve6DRs2rwSat+XAdgRncPh7VBoNAABwbMd4Pq/U3gAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxOS0wNS0yMFQwOTowNDoyNiswOTowMOwn1y0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTktMDUtMjBUMDk6MDQ6MjYrMDk6MDCdem+RAAAAAElFTkSuQmCC' }
    sequence(:order ){|n| n }
    is_done { false }
  end
end
