class UploadSanitizer
  attr_reader :name

  SPECIAL_CHARACTERS = ['%', '$', '&', '=', '@', ':', '+',
                        ',', '?', '{', '}', "\\", "\[", "\]",
                        '<', '>', '#', '^', '`']

  def initialize(name)
    @name = name
  end

  def new_name
    temp = name.delete(SPECIAL_CHARACTERS.join)
    extension = temp.split(".").last
    temp.delete! ".#{extension}"
    if temp.blank?
      "#{random_name}.#{extension}"
    else
      "#{temp}.#{extension}"
    end
  end

  private

  def random_name
    ('a'..'z').to_a.shuffle[0,10].join
  end
end
