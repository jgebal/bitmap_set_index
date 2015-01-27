require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Perform BIT OR operation on encoded bitmaps' do

  include_context 'shared bitmap builder'

  it 'should return empty bitmap if one of input bitmaps is empty' do
    expect(bit_or( [nil], [1, nil, 3] )).to eq([])
  end

  it 'should return the same bitmap if both bitmaps are equal' do
    bit_map = [1,2,3,4]
    expect(bit_or( bit_map, bit_map )).to eq(bit_map)
  end

  it 'should return union of bitmaps when they have something in common' do
    left_bits  = [1,2,3,4,30,31,32,140,3000,     12888]
    right_bits = [1,  3,4,   31,32,140,     3500,12888,25000]
    expected   = [1,2,3,4,30,31,32,140,3000,3500,12888,25000]
    expect(bit_or( left_bits, right_bits )).to eq(expected)
  end

  it 'should return bitmap containing all elements of both input bitmaps when bitmaps have nothing in common' do
    left_bits  = [1,2,3,4,           30,31,32,      140,    3000,      12888]
    right_bits = [        5,6,7,8,29,         33,34,    141,     3500,      23999,25000]
    expected   = [1,2,3,4,5,6,7,8,29,30,31,32,33,34,140,141,3000,3500,12888,23999,25000]
    expect(bit_or( left_bits, right_bits )).to eq(expected)
  end
end
