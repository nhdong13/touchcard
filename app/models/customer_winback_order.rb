class CustomerWinbackOrder < CardOrder
  after_initialize :ensure_defaults

  def ensure_defaults
    super
  end

  def name
  end

  def description
  end
end
