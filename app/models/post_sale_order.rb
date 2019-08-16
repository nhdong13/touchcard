class PostSaleOrder < CardOrder
  after_initialize :ensure_defaults

  def ensure_defaults
    self.send_delay = 2 unless self.send_delay > 0 # it starts initialized to 0
    super
  end

  def name
    "Post sale card"
  end

  def description
    "Send postcard to you customer after they made purchase!"
  end
end
