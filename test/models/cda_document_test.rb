require 'test_helper'

class CdaDocumentTest < ActiveSupport::TestCase
  FHIRServer.stub :upload_to_server, nil do

    test 'parse c32' do
      xml = File.read('test/fixtures/c32.xml')
      doc = CdaDocument.build_document(xml)
      assert_equal C32Document, doc.class
    end

    test 'parse ccda' do
      xml = File.read('test/fixtures/ccda.xml')
      doc = CdaDocument.build_document(xml)
      assert doc.is_a? CcdaDocument
    end

    test 'parse non cda xml' do
      xml = File.read('test/fixtures/not_cda.xml')
      assert_raise CDA::ParsingException do
        CdaDocument.build_document(xml)
      end
    end

    test 'parse junk document' do
      xml = File.read('test/fixtures/junk.xml')
      assert_raise CDA::ParsingException do
        CdaDocument.build_document(xml)
      end
    end

  end

end
