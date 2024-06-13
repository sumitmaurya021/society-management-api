PDFKit.configure do |config|
    config.wkhtmltopdf = 'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
    config.default_options = {
        page_size: 'A4',
        print_media_type: true
    }
end