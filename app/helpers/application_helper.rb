module ApplicationHelper
  def current_class?(path)
    path == request.path ? 'is-active' : ''
  end
end
