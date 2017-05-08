class AddPriceRuleIdToPostcards < ActiveRecord::Migration
  def change
    add_column :postcards, :price_rule_id, :integer
  end
end
