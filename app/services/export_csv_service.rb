require "csv"

class ExportCsvService
  def initialize objects, attributes
    @attributes = attributes
    @objects = JSON.parse(objects)
    @header = attributes
  end

  def perform
    CSV.generate do |csv|
      csv << @header
      objects.each do |object|
        csv << @attributes.map{ |attr| object[attr] }
      end
    end
  end

  private
  attr_reader :attributes, :objects
end
