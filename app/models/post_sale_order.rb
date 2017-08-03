class PostSaleOrder < CardOrder
  after_initialize :ensure_defaults

  def ensure_defaults
    self.send_delay = 0 if send_delay.nil?
    super
  end
end
