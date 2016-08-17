require 'os'

class FhirUploadJob < ActiveJob::Base
  queue_as :default

  def perform(json)
    json_file = Tempfile.new('patient_json')
    json_file.write(json)
    json_file.close
    upload_executable = ""
    if OS.linux?
      upload_executable = "bin/upload-linux"
    end
    if OS.mac?
      upload_executable = "bin/upload-mac"
    end

    if ENV["FHIR_URL"].nil?
      fhir_server_url = "http://localhost:3001"
    else
      fhir_server_url = ENV["FHIR_URL"]
    end

    `#{upload_executable} -f #{fhir_server_url} -s #{json_file.path} -c`
    json_file.unlink
  end
end
