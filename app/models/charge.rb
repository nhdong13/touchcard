class Charge < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_template

end
