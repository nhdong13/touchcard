ActiveAdmin.register_page "Change Password" do
  menu priority: 17

  content do
    render "change_password"
  end

  page_action "change", :method => :put do
    if params[:new_password].present? && params[:confirmation].present? && params[:new_password] != params[:confirmation] && current_admin_user.update(password: params[:new_password])
      flash[:notice] = 'Successfully update password'
    else
      flash[:error] = 'Failed to update password'
    end
    redirect_to admin_change_password_path
  end
end
