require 'test_helper'

class FhirServerTest < ActiveSupport::TestCase
  test 'upload to dead server' do
    xml = File.read('test/fixtures/ccda.xml')
    doc = CdaDocument.build_document(xml)
    assert_raise RuntimeError do
      FHIRServer.upload(doc)
    end
  end
end
