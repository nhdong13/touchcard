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
    last_period_index = temp.rindex('.')

    if last_period_index != nil and temp.slice(0, last_period_index).length == 0
      "#{random_name}.#{extension}"
    else
      temp
    end
  end

  private

  def random_name
    ('a'..'z').to_a.shuffle[0,10].join
  end
end
