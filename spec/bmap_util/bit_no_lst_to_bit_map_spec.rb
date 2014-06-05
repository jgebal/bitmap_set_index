require_relative '../spec_helper'

describe 'bit no list to bit_map' do

  it 'should fail if NULL parameter given' do
    expect{
        plsql.bmap_util.bit_no_lst_to_bit_map()
    }.to raise_exception
  end

  it 'should return a bitmap for given parameters' do
    result = plsql.bmap_util.bit_no_lst_to_bit_map([1,2,3,4])
    result.should == [[15],[1],[1],[1],[1],[1],[1],[1]]
  end
end
