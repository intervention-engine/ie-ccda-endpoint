require 'fhir/server'

# CCDA Creation endpoint
class CcdaController < ApplicationController
  def create
    document = CdaDocument.build_document(request.body)

    upload(document)

    @status ||= :ok
    @message ||= 'Document Uploaded'

    render plain: @message, status: @status
  end

  private

  def upload(document)
    FHIR::Server.upload(document)
  rescue CDA::ParsingException => e
    @message = e.message
    @status = 400
  rescue RuntimeError => e
    @message = e.message
    @status = 500
  end
end
