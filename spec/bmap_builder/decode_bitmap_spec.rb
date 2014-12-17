require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Convert hierarchical bitmap to list of bit numbers' do

  before(:all) {
    plsql.dbms_output_stream = STDOUT
  }

  it 'should return empty list if empty list parameter given' do
    decode_bitmap( encode_bitmap( nil ) ).should == []
  end

  it 'should ignore if NULL parameter present on list' do
    list = [1,nil,3]
    expected = list.reject{ |e| e.nil? }
    result = decode_bitmap( encode_bitmap( list ) )
    result.should == expected
  end

  it 'should decode encoded bitmap to a list ' do
    list = (1..1400).to_a
    expected = list.reject{ |e| e.nil? }
    result = decode_bitmap( encode_bitmap( list ) )
    result.should == expected
  end

end
