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
          # Fix encounter codes that have null code but predictable originalText
          enc_codes = doc.xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry/cda:encounter/cda:code")
          enc_codes.each do | enc_code |
            if !enc_code.nil? && enc_code['nullFlavor'] == "UNK" && enc_code['code'].nil?
              original_text = enc_code.at_xpath("cda:originalText").text
              case original_text
              when 'Emergency'
                enc_code.delete 'nullFlavor'
                enc_code['code'] = '50849002'
                enc_code['codeSystem'] = '2.16.840.1.113883.6.96'
                enc_code['codeSystemName'] = 'SNOMED-CT'
                enc_code['displayName'] = 'Emergency room admission'
              when 'Inpatient'
                enc_code.delete 'nullFlavor'
                enc_code['code'] = '32485007'
                enc_code['codeSystem'] = '2.16.840.1.113883.6.96'
                enc_code['codeSystemName'] = 'SNOMED-CT'
                enc_code['displayName'] = 'Hospital admission'
              when 'Observation'
                enc_code.delete 'nullFlavor'
                enc_code['code'] = '448951000124107'
                enc_code['codeSystem'] = '2.16.840.1.113883.6.96'
                enc_code['codeSystemName'] = 'SNOMED-CT'
                enc_code['displayName'] = 'Admission to observation unit'
              else
                puts "Cannot infer encounter code from unrecognized originalText: #{original_text}"
              end
            end
          end
          patient_data =  HealthDataStandards::Import::CCDA::PatientImporter.instance.parse_ccda(doc)
      end
    end

    # TODO: Fix encounter codes that have no code

    patient_json = patient_data.to_json

    File.open('patient.json', 'w+') do |f|
      f.write(patient_json)
    end

    FhirUploadJob.perform_later(patient_json)
    render nothing: true
  end

end
