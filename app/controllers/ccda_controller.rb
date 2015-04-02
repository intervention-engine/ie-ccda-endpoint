require 'json'
require_relative '../../lib/provider_import_utils'

class CcdaController < ApplicationController

  def create
    doc = Nokogiri::XML(request.body)

    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

    root_element_name = doc.root.name

    if root_element_name == 'ClinicalDocument'
      if doc.at_xpath("/cda:ClinicalDocument/cda:templateId[@root='2.16.840.1.113883.3.88.11.32.1']")
          patient_data =  HealthDataStandards::Import::C32::PatientImporter.instance.parse_c32(doc)
      elsif doc.at_xpath("/cda:ClinicalDocument/cda:templateId[@root='2.16.840.1.113883.10.20.22.1.2']")
          patient_data =  HealthDataStandards::Import::CCDA::PatientImporter.instance.parse_ccda(doc)
      end
    end

    patient_json = patient_data.to_json

    File.open('patient.json', 'w+') do |f|
      f.write(patient_json)
    end

    FhirUploadJob.perform_later(patient_json)
    render nothing: true
  end

end
