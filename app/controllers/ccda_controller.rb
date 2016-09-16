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
          patient_data = HealthDataStandards::Import::C32::PatientImporter.instance.parse_c32(doc)
      elsif doc.at_xpath("/cda:ClinicalDocument/cda:templateId[@root='2.16.840.1.113883.10.20.22.1.2']")
          # Fix encounter codes that have null code but predictable originalText
          enc_codes = doc.xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry/cda:encounter/cda:code")
          enc_codes.each do | enc_code |
            if !enc_code.nil? && enc_code['nullFlavor'] == "UNK" && enc_code['code'].nil?
              self.fix_encounter_code(enc_code)
            end
          end
          patient_data =  HealthDataStandards::Import::CCDA::PatientImporter.instance.parse_ccda(doc)
      elsif doc.at_xpath("/cda:ClinicalDocument/cda:templateId[@root='2.16.840.1.113883.10.20.24.1.1']")
        patient_data = HealthDataStandards::Import::Cat1::PatientImporter.instance.parse_cat1(doc)
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

  def fix_encounter_code(enc_code)
    text = enc_code.parent.at_xpath("cda:text")
    original_text = enc_code.at_xpath("cda:originalText").text
    case original_text
    when 'Emergency'
      insert_code(enc_code, '50849002', text, original_text)
    when 'Inpatient'
      insert_code(enc_code, '32485007', text, original_text)
    when 'Observation'
      insert_code(enc_code, '448951000124107', text, original_text)
    else
      puts "Cannot infer encounter code from unrecognized originalText: #{original_text}"
    end
  end

  def insert_code(code_node, code, text_node, description)
    code_node.delete 'nullFlavor'
    code_node['code'] = code
    code_node['codeSystem'] = '2.16.840.1.113883.6.96'
    code_node['codeSystemName'] = 'SNOMED-CT'
    if text_node.nil?
      code_node.add_next_sibling "<text>#{description}</text>"
    elsif text_node.content.strip.blank? && text_node.children.empty?
      text_node.content = description
    end
  end
end
