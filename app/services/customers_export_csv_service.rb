class CustomersExportCsvService
  attr_reader :objects, :filters

  def initialize objects, filters
    @objects = objects
    @filters = filters
  end

  def perform
    CSV.generate do |csv|
      csv << (["No."] + filters).flatten
      objects.values.each.with_index(1) do |object, i|
        csv << [i] + object
      end
    end
  end
end
