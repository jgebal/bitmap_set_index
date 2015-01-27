require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Perform BIT MINUS operation on encoded bitmaps' do

  include_context 'shared bitmap builder'

  it 'should return empty bitmap if one of input bitmaps is empty' do
    expect(segment_bit_minus( [nil], [1, nil, 3] )).to eq([])
  end

  it 'should return empty bitmap if both bitmaps are equal' do
    bit_map = [1,2,3,4]
    expect(segment_bit_minus( bit_map, bit_map )).to eq([])
  end

  it 'should return all bits from left bitmap except the bits in common with right side' do
    left_bits  = [1,2,3,4,30,31,32,140,3000,      12888]
    right_bits = [1,  3,4,   31,32,140,      3500,12888,25000]
    expected   = [  2,    30,          3000]
    expect(segment_bit_minus( left_bits, right_bits )).to eq(expected)
  end

  it 'should return unchanged left bitmap when bitmaps have nothing in common' do
    left_bits  = [1,2,3,4,30,31,32,140,3000,12888]
    right_bits = [5,6,7,8,29,33,34,141,3500,23999,25000]
    expect(segment_bit_minus( left_bits, right_bits )).to eq(left_bits)
  end

  it 'should return empty bitmap when right bitmap is bigger then the left bitmap' do
    left_bits  = [1,2,3,4,30,31,32,140,3000,12888]
    right_bits = left_bits + [5,6,7,8,29,33,34,141,3500,23999,25000]
    expect(segment_bit_minus( left_bits, right_bits )).to eq([])
  end
end
