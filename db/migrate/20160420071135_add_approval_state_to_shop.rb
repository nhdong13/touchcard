class AddApprovalStateToShop < ActiveRecord::Migration
  def change
    add_column :shops, :approval_state, :string, index: true, null: false, default: "new"
  end
end
