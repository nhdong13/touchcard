module NavigationHelper
  def nav_tab(title, url, options)
    current_tab = options.delete(:current)
    options[:class] = (current_tab == title) ? "mdc-tab--active mdc-tab" : "mdc-tab"
    link_to title, url, options
  end

  def currently_at(tab)
    render partial: "layouts/main_nav", locals: { current_tab: tab }
  end
end
