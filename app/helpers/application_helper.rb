module ApplicationHelper
  def current_class?(path)
    path == request.path ? 'mdc-tab--active' : ''
  end
end
