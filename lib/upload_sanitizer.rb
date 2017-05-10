class UploadSanitizer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def sanitize
    # Remove any character that aren't 0-9, A-Z, or a-z
    result = name.gsub(/[^0-9A-Z.]/i, '_')
    result = "_" + result if result[0] == '.'
    result
  end
end
