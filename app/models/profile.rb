# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  first_name          :string
#  zip_code            :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  language_id         :integer
#  library_location_id :integer
#

class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :language
  belongs_to :library_location

  validates :first_name, presence: true
  validates :zip_code, format: { with: /\A\d{5}-\d{4}|\A\d{5}\z/, message: "should be ##### or #####-####" },
    allow_blank: true
end
