class ExportCsvService
  attr_reader :objects, :filters

  def initialize objects, filters
    @objects = objects
    @filters = filters
  end

  def perform
    CSV.generate do |csv|
      csv << ["No.", "Fullname"]
      objects.each.with_index do |object, i|
        csv << [i, object.public_send('full_name')]
      end
    end
  end
end
