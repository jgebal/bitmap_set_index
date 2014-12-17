require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Perform Bit AND operation on encoded bitmaps' do

  before(:all) {
    plsql.dbms_output_stream = STDOUT
    @bits_in_segment = plsql.bmap_builder.get_index_length
    @max_bit_number = plsql.bmap_builder.c_max_bits
  }

  it 'should return empty bitmap if one of input bitmaps is empty' do
    bit_and( encode_bitmap(nil), encode_bitmap(1, nil, 3) ).should == []
  end

  it 'should return the same bitmap if both bitmaps are equal' do
    bit_map = encode_bitmap(1,2,3,4)
    bit_and( bit_map, bit_map ).should == bit_map
  end
end
