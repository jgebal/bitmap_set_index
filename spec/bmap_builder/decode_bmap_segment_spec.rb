require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Convert hierarchical bitmap to list of bit numbers' do

  include_context 'shared bitmap builder'

  it 'should return empty list if empty list parameter given' do
    expect(encode_and_decode_bmap( nil )).to eq([])
  end

  it 'should ignore if NULL parameter present on list' do
    list = [1,nil,3]
    expected = list.reject{ |e| e.nil? }
    result = encode_and_decode_bmap( list )
    expect(result).to eq(expected)
  end

  it 'should decode encoded bitmap to a list ' do
    expected = (1..27000).to_a
    result = encode_and_decode_bmap( expected )
    expect(result).to eq(expected)
  end

  it 'should decode bitmap with last segment set ' do
    expected = ( ((@max_bit_number-(@bits_in_segment-1))..@max_bit_number).to_a )
    result = encode_and_decode_bmap( expected  )
    expect(result).to eq(expected)
  end

end