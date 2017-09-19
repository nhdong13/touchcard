ActiveAdmin.register Address do
  menu priority: 15
  actions :index, :show
  # menu false

  filter :first_name
  filter :last_name
  filter :province
  filter :province_code
  filter :country
  filter :country_code
  filter :default



  index do
    column :id do |address|
      link_to address.id, admin_address_path(address)
    end
    column :first_name
    column :last_name
    column :province_code
    column :country_code
    column :customer_id
    column :default
    # actions
  end

  show do
    attributes_table do
      row :id
      row :address1
      row :address2
      row :city
      row :company
      row :country
      row :country_code
      row :first_name
      row :last_name
      row :latitude
      row :longitude
      row :phone
      row :province
      row :zip
      row :name
      row :text
      row :province_code
      row :customer_id do |address|
        link_to(address.customer.id, admin_customer_path(address.customer))
      end
    end
  end
end
