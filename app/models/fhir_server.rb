require 'open3'
# Gateway for FHIR server
module FHIRServer

  ERROR_REGEX = /: (.*?):/
  URL = ENV['FHIR_URL'] || 'http://localhost:3001'

  if OS.linux?
    EXEC = 'bin/upload-linux'
  elsif OS.mac?
    EXEC = 'bin/upload-mac'
  else
    raise 'Invalid Deployment OS'
  end

  def self.upload(document)
    json = document.data.to_json
    json_file = Tempfile.new('patient_json')
    json_file.write(json)
    json_file.close

    x = upload_to_server(json_file)
    json_file.unlink
    x
  end

  def self.upload_to_server(file)
    _, err, status = Open3.capture3("#{EXEC} -f #{URL} -s #{file.path} -c")

    raise ERROR_REGEX.match(err)[1] unless status.success?
  end
end
