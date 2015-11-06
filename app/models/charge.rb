class Charge < ActiveRecord::Base
  belongs_to :shop
  belongs_to :card_template

  def canceling
    self.update_attribute(:status, "canceling")
  end
end
