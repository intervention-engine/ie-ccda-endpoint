# CCDA Creation endpoint
class CcdaController < ActionController::Metal
  include AbstractController::Rendering

  def create
    status = :ok
    message = 'Document Uploaded'

    begin
      document = CdaDocument.new(request.body)
      FHIRServer.upload(document)
    rescue CDA::ParsingException => e
      message = e.message
      status = :bad_request
    rescue RuntimeError => e
      message = e.message
      status = 502
    rescue Error => e
      message = e.message
      status = :server_error
    end

    render plain: message, status: status
  end
end
