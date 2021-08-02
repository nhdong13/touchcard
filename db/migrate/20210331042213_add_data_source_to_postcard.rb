class AddDataSourceToPostcard < ActiveRecord::Migration[5.2]
  def change
    add_column :postcards, :data_source_status, :string, default: "normal"
  end
end
