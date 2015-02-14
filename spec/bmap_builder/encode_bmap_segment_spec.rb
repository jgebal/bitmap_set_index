require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Convert list of bit numbers to hierarchical bitmap' do

  include_context 'shared bitmap builder'

  it 'should return empty bitmap if empty list parameter given' do
    expect(encode_and_decode_bmap( nil )).to eq([])
  end

  it 'should return a bitmap for given parameters' do
    bit_list = [1, 2, 3, 4]
    result = encode_and_decode_bmap(bit_list)
    expect(result).to eq(bit_list)
  end

  it 'should fail if bit number is exceeds maximum allowed number' do
    expect{
      encode_and_decode_bmap(@max_bit_number + 1)
    }.to raise_exception
  end

  it 'should not fail if bit number is equal to maximum allowed number' do
    expect{
      encode_and_decode_bmap([@max_bit_number])
    }.not_to raise_exception
  end

end
