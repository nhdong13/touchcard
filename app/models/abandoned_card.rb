class AbandonedCard < CardOrder
  after_initialize :ensure_defaults

  def ensure_defaults
    super
  end

  def name
    "Abandoned checkout card"
  end

  def description
    "Engage customers that abandoned their checkout to buy from you shop!"
  end
end
