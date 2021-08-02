class DatetimeService
  def initialize datetime
    @datetime = datetime
  end

  def to_date
    return "/" unless @datetime
    @datetime.strftime("%b %d, %Y")
  end
end