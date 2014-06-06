require_relative '../spec_helper'

describe 'Convert list of bit numbers to hierarchical bitmap' do

  before(:each) {
    @bits_in_segment = plsql.bmap_util.get_index_length
    @max_bit_number = plsql.bmap_util.c_max_bits
  }

  it 'should return empty bitmap if empty list parameter given' do
    convert_bit_list_to_hierarchical_bitmap().should == []
  end

  it 'should ignore if NULL parameter present on list' do
    result = convert_bit_list_to_hierarchical_bitmap(1, nil, 3)
    result.should == [[5],[1],[1],[1],[1]]
  end

  it 'should return a bitmap for given parameters' do
    result = convert_bit_list_to_hierarchical_bitmap(1,2,3,4)
    result.should == [[15],[1],[1],[1],[1]]
  end

  it 'should fail if bit number is exceeds maximum allowed number' do
    expect{
      convert_bit_list_to_hierarchical_bitmap(@max_bit_number + 1)
    }.to raise_exception
  end

  it 'should not fail if bit number is equal to maximum allowed number' do
    expect{
      convert_bit_list_to_hierarchical_bitmap(@max_bit_number)
    }.not_to raise_exception
  end

  it 'should create bitmap with multiple segments on first two levels' do
    result = convert_bit_list_to_hierarchical_bitmap(1, @bits_in_segment**2+1)
    result.should == [ ([1] + [NULL]*(@bits_in_segment-1) + [1]),[1,1],[3],[1],[1]]
  end

  def convert_bit_list_to_hierarchical_bitmap(*bit_number)
    plsql.bmap_util.bit_no_lst_to_bit_map(bit_number)
  end

end
