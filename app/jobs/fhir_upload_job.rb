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

    `#{upload_executable} -f http://localhost:3001 -s #{json_file.path}`
    json_file.unlink
  end
end
