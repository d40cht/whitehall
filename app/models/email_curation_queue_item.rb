class EmailCurationQueueItem < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :title, :summary, :notification_date, presence: true

  def self.create_from_edition(edition, notification_date)
    create(edition: edition, title: edition.title, summary: edition.summary, notification_date: notification_date)
  end
end