require 'fhir/server'

# CCDA Creation endpoint
class CcdaController < ActionController::Metal
  include AbstractController::Rendering

  def create
    document = CdaDocument.new(request.body)

    upload(document)

    @status ||= :ok
    @message ||= 'Document Uploaded'

    render plain: message, status: status
  end

  private

  def upload(document)
    FHIR::Server.upload(document)
  rescue CDA::ParsingException => e
    @message = e.message
    @status = :bad_request
  rescue RuntimeError => e
    @message = e.message
    @status = :bad_request
  end
end
