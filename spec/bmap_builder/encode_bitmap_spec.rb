require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Convert list of bit numbers to hierarchical bitmap' do

  before(:all) {
    plsql.dbms_output_stream = STDOUT
    @bits_in_segment = plsql.bmap_builder.get_index_length
    @max_bit_number = plsql.bmap_builder.c_max_bits
  }

  it 'should return empty bitmap if empty list parameter given' do
    encode_bitmap( nil ).should == []
  end

  it 'should ignore if NULL parameter present on list' do
    result = encode_bitmap(1, nil, 3)
    result.should == [[5],[1],[1],[1],[1]]
  end

  it 'should return a bitmap for given parameters' do
    result = encode_bitmap(1,2,3,4)
    result.should == [[15],[1],[1],[1],[1]]
  end

  it 'should fail if bit number is exceeds maximum allowed number' do
    expect{
      encode_bitmap(@max_bit_number + 1)
    }.to raise_exception
  end

  it 'should not fail if bit number is equal to maximum allowed number' do
    expect{
      encode_bitmap(@max_bit_number)
    }.not_to raise_exception
  end

  it 'should create bitmap with multiple segments on first two levels' do
    result = encode_bitmap( 1, @bits_in_segment**2+1 )
    result.should == [ ([1,1]),[1,1],[3],[1],[1]]
  end

  it 'should create bitmap with multiple segments on different levels' do
    result = encode_bitmap( set_bit_in_segment(1,1), set_bit_in_segment(3,5), set_bit_in_segment(2,10) )
    result.should == [ [1,4,2], [(1 + 2**4 + 2**9)],[1],[1],[1]]
  end

  it 'should create bitmap with second segment set on second level' do
    result = encode_bitmap(set_bit_in_segment(1,2))
    result.should == [ [1],[2],[1],[1],[1]]
  end

end
