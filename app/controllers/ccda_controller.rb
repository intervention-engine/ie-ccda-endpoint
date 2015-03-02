require 'json'

class CcdaController < ApplicationController

  def create
    doc = Nokogiri::XML(xml_data)
    patient_data = HealthDataStandards::Import::CCDA::PatientImporter.instance.parse_ccda(doc)
    record = HealthDataStandards::Record.update_or_create(patient_data)
    File.open('patient_json/' + record.medical_record_number + '.json') do |f| {
      f.write(record.to_json)
    }
  end

end
