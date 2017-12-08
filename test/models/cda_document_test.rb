require 'test_helper'
require 'fhir/server'
require 'cda_document'

class CdaDocumentTest < ActiveSupport::TestCase

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

    # test 'parse cda with exact duplicate entry' do
    #   xml = File.read('test/fixtures/ccda_dup.xml')
    #   doc = CdaDocument.build_document(xml).data
    #   conditions = doc.conditions.select do |c|
    #     c.codes == { 'SNOMED-CT' => ['194828000'] } && c.as_point_in_time == 1_373_414_400
    #   end
    #
    #   assert_equal 1, conditions.size, conditions.map(&:as_point_in_time)
    #   assert_not_nil conditions.first.end_time
    # end

    test 'parse cda with duplicate entry setwise' do
      xml = File.read('test/fixtures/ccda_dup_setwise.xml')
      doc = CdaDocument.build_document(xml).data
      conditions = doc.conditions.select do |c|
        c.codes == { 'SNOMED-CT' => ['194828000'] } && c.as_point_in_time == 1_373_414_400
      end

      # byebug

      assert_equal 1, conditions.size, conditions.map(&:as_point_in_time)
      assert_not_nil conditions.first.end_time
    end

    test 'parse junk document' do
      xml = File.read('test/fixtures/junk.xml')
      assert_raise CDA::ParsingException do
        CdaDocument.build_document(xml)
      end
    end

end
