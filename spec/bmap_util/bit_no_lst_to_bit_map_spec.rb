require_relative '../spec_helper'

describe 'Convert list of bit numbers to hierarchical bitmap' do

  it 'should fail if NULL parameter given' do
    expect{
        plsql.bmap_util.bit_no_lst_to_bit_map()
    }.to raise_exception
  end

  it 'should return a bitmap for given parameters' do
    result = plsql.bmap_util.bit_no_lst_to_bit_map([1,2,3,4])
    result.should == [[15],[1],[1],[1],[1]]
  end

  it 'should fail if bit number is exceeds maximum allowed number' do
    max_bit_allowed = plsql.bmap_util.c_max_bits
    expect{
        plsql.bmap_util.bit_no_lst_to_bit_map([max_bit_allowed + 1])
    }.to raise_exception
  end

  it 'should not fail if bit number is equal to maximum allowed number' do
    max_bit_allowed = plsql.bmap_util.c_max_bits
    plsql.bmap_util.bit_no_lst_to_bit_map([max_bit_allowed])
  end

end
