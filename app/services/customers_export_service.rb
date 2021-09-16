class CustomersExportService
  attr_reader :lines, :filters, :sheet, :styles
  require "axlsx"

  def initialize lines, filters
    @lines = lines
    @filters = filters
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

    #Add section divider
    add_section_divider
    # Format id column to string
    sheet["A3:A#{sheet.rows.size}"].each{ |cell| cell.type = :string }
    sheet["L3:L#{sheet.rows.size}"].each{ |cell| cell.type = :string }

    # Generate file and return file
    send_excel_file(book)
  end

  # Export customer list to compare who filtered out
  # =begin
  CUSTOMER_DATA_COLUMNS_COUNT = 4
  def create_compare_xlsx accepted_filters, removed_filters
    book = Axlsx::Package.new
    workbook = book.workbook
    @styles = workbook.styles
    @sheet = workbook.add_worksheet name: "Customer List"
    
    # Add header
    sheet.add_row(Array.new(CUSTOMER_DATA_COLUMNS_COUNT, "CUSTOMER") + accepted_filters.map{|f| [f, ""]}.flatten + removed_filters.map{|f| [f, ""]}.flatten)
    sheet.merge_cells sheet.rows.first.cells[(0..CUSTOMER_DATA_COLUMNS_COUNT - 1)]
    (accepted_filters.size + removed_filters.size).times.each do |index|
      sheet.merge_cells sheet.rows.first.cells[(CUSTOMER_DATA_COLUMNS_COUNT + index*2 ... CUSTOMER_DATA_COLUMNS_COUNT + index*2 + 2)]
    end
    # Add Subheader
    column_names_style = styles.add_style({ bg_color: "ddebf7", b: true })
    sheet.add_row(["ID", "Email", "Fullname", "Passed?", (1..accepted_filters.size + removed_filters.size).map{|i| ["Customer data", "Passed?"]}].flatten).style = column_names_style

    # Add header style
    customer_section_style = styles.add_style(centered_column_header("000000"))
    accept_section_style   = styles.add_style(centered_column_header("70ad47"))
    remove_section_style   = styles.add_style(centered_column_header("ff0000"))
    sheet.rows.first.cells[(0..CUSTOMER_DATA_COLUMNS_COUNT - 1)].each{|cell| cell.style = customer_section_style }
    sheet.rows.first.cells[(CUSTOMER_DATA_COLUMNS_COUNT..accepted_filters.size*3 + CUSTOMER_DATA_COLUMNS_COUNT - 1)].each{|cell| cell.style = accept_section_style }
    sheet.rows.first.cells[(accepted_filters.size*3 + CUSTOMER_DATA_COLUMNS_COUNT..accepted_filters.size*3 + removed_filters.size*3 + CUSTOMER_DATA_COLUMNS_COUNT - 1)].each{|cell| cell.style = remove_section_style }

    # Add data
    lines.each.with_index(1) do |line, i|
      sheet.add_row(line)
    end
    send_excel_file(book)
  end
  # =end

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
    (EXPORT_FILE_SECTIONS + [["FILTERS", filters.length + 2, "7030a0"]]).each do |section|
      head.push(section[0]).push(Array.new((section[1] - 1), "")).flatten!
    end
    sheet.add_row head
  end

  def merge_headers
    pointer = 0
    (EXPORT_FILE_SECTIONS + [["FILTERS", filters.length + 2, "7030a0"]]).each do |section|
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

  def add_section_divider
    right_border = styles.add_style({ border: { style: :thin, color: '000000', edges: [:right] } })
    column_name_with_right_border = styles.add_style({ bg_color: "ddebf7", b: true, border: { style: :thin, color: '000000', edges: [:right] } })
    
    # Add empty line below all data
    empty_line_data = Array.new(sheet.column_info.count)
    20.times.each{|i| sheet.add_row empty_line_data}

    number_of_rows = sheet.rows.count
    ["K2:K#{number_of_rows}",
     "T2:T#{number_of_rows}",
     "X2:X#{number_of_rows}",
     "Z2:Z#{number_of_rows}",
     "AC2:AC#{number_of_rows}"
    ].each {|cells| sheet[cells].each{|cell| cell&.style = cell&.row&.index == 1 ? column_name_with_right_border : right_border } }
  end

  def centered_column_header color
    { 
      alignment: {
        horizontal: :center,
        vertica: :center,
        wrap_text: true
      },
      bg_color: color, fg_color: "ffffff", b: true
    }
  end
end
