require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Perform BIT AND operation on encoded bitmaps' do

  include_context 'shared bitmap builder'

  it 'should return empty bitmap if one of input bitmaps is empty' do
    expect(bit_and( [nil], [1, nil, 3] )).to eq( [] )
  end

  it 'should return the same bitmap if both bitmaps are equal' do
    bit_map = [1,2,3,4]
    expect(bit_and( bit_map, bit_map )).to eq(bit_map)
  end

  it 'should return common part when bitmaps are different' do
    left_bits  = [1,2,3,4,30,31,32,140,30000,      128888]
    right_bits = [1,  3,4,   31,32,140,      35000,128888,2800000]
    expected   = [1,  3,4,   31,32,140,            128888]
    expect(bit_and( left_bits, right_bits )).to eq(expected)
  end

  it 'should return empty bitmap when bitmaps have nothing in common' do
    left_bits  = [1,2,3,4,30,31,32,140,30000,128888]
    right_bits = [5,6,7,8,29,33,34,141,35000,239999,2800000]
    expected   = []
    expect(bit_and( left_bits, right_bits )).to eq(expected)
  end
end
