class AddPriceRuleIdToPostcards < ActiveRecord::Migration[4.2]
  def change
    add_column :postcards, :price_rule_id, :bigint
  end
end
