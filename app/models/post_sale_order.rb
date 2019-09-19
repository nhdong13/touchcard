class PostSaleOrder < CardOrder
  after_initialize :ensure_defaults

  def ensure_defaults
    super
  end

  def name
    "Post sale card"
  end

  def description
    "Send postcard to you customer after they made purchase!"
  end
end
