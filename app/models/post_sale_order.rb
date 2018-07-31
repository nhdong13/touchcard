class PostSaleOrder < CardOrder
  after_initialize :ensure_defaults

  def ensure_defaults
    self.send_delay = 0 if send_delay.nil?
    super
  end

  def name
    "Post sale card"
  end

  def description
    "Send postcard to you customer after they made purchase!"
  end
end
