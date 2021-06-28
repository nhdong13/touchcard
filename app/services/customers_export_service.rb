class CustomersExportService
  attr_reader :lines, :filters, :sheet, :styles
  require "axlsx"

  def initialize lines, filters
    @lines = lines
    @filters = filters&.map(&:capitalize)
  end

  def create_xlsx
    book = Axlsx::Package.new
    workbook = book.workbook
    @styles = workbook.styles
    @sheet = workbook.add_worksheet name: "Customer List"

    # Add Headers
    add_headers_section
    merge_headers

    # Add Column names
    column_names_style = styles.add_style({ bg_color: "ddebf7", b: true })
    sheet.add_row((EXPORT_FILE_COLUMNS + filters).flatten).style = column_names_style
    
    # Add data
    lines.each.with_index(1) do |line, i|
      sheet.add_row(line + Array.new(28, ""))
    end
    
    # Generate file and return file
    send_excel_file(book)
  end

  private
  def send_excel_file book
    tmp_file_path = "#{Rails.root}/tmp/customers.xlsx"
    book.serialize tmp_file_path
    filename = "customers.xlsx"
    file_content = File.read(tmp_file_path)
    File.delete tmp_file_path
    file_content
  end

  def add_headers_section
    head = []
    (EXPORT_FILE_SECTIONS + [["FILTERS", filters.length, "7030a0"]]).each do |section|
      head.push(section[0]).push(Array.new((section[1] - 1), "")).flatten!
    end
    sheet.add_row head
  end

  def merge_headers
    pointer = 0
    (EXPORT_FILE_SECTIONS + [["FILTERS", filters.length, "7030a0"]]).each do |section|
      sheet.merge_cells sheet.rows.first.cells[(pointer..pointer + section[1] - 1)]
      current_section_style = styles.add_style({ 
        alignment: {
          horizontal: :center,
          vertica: :center,
          wrap_text: true
        },
        bg_color: section[2], fg_color: "ffffff", b: true
      })
      sheet.rows.first.cells[(pointer..pointer + section[1] -1)].first.style = current_section_style
      pointer += section[1]
    end
  end
end