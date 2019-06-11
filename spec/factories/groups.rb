# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    owner_id { User.first ? User.first.id : create(:user).id }
    name { 'MyString' }
    image { 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAAAAAAeW/F+AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAAmJLR0QA/4ePzL8AAAAHdElNRQfjBRQABBrSkbBKAAAAT0lEQVQoz2M4gxcwjEoPkPSmjau3rNoEFULmQKSPr18/59icM2e27d2J4MClTx05Mn8+SOTUIiQOQve6DRs2rwSat+XAdgRncPh7VBoNAABwbMd4Pq/U3gAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxOS0wNS0yMFQwOTowNDoyNiswOTowMOwn1y0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTktMDUtMjBUMDk6MDQ6MjYrMDk6MDCdem+RAAAAAElFTkSuQmCC' }
  end
end
