require 'test_helper'
require 'fhir/server'

class CcdaControllerTest < ActionController::TestCase
  test 'upload ccda' do
    upload('test/fixtures/ccda.xml')
  end

  test 'upload c32' do
    upload('test/fixtures/c32.xml')
  end

  def upload(file_name)
    FHIR::Server.stub :upload_to_server, nil do
      output = File.read(file_name)
      # request.env['RAW_POST_DATA'] = output
      post :create, output
      assert_response :ok, response.body
      assert_equal 'Document Uploaded', response.body
    end
  end
end
