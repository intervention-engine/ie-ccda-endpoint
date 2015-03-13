require 'json'

class CcdaController < ApplicationController

  def create
    doc = Nokogiri::XML(request.body)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    patient_data = HealthDataStandards::Import::CCDA::PatientImporter.instance.parse_ccda(doc)
    patient_json = patient_data.to_json
    File.open('patient.json', 'w+') do |f|
      f.write(patient_json)
    end
    FhirUploadJob.perform_later(patient_json)
    render nothing: true
  end

end
