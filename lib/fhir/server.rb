require 'open3'
module FHIR
  # Gateway for FHIR server
  module Server
    ERROR_REGEX = /: (.*?):/
    URL = ENV['FHIR_URL'] || 'http://localhost:3001'

    if OS.linux?
      EXEC = 'bin/upload-linux'.freeze
    elsif OS.mac?
      EXEC = 'bin/upload-mac'.freeze
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

      return if status.success?
      raise ERROR_REGEX.match(err)[1]
    end
  end
end
