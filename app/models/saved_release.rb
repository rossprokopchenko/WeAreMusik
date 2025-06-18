class SavedRelease < ApplicationRecord
  belongs_to :user
  belongs_to :release, class_name: 'Release'
end