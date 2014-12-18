require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Convert hierarchical bitmap to list of bit numbers' do

  include_context 'shared bitmap builder'

  it 'should return empty list if empty list parameter given' do
    decode_bitmap( encode_bitmap( nil ) ).should == []
  end

  it 'should ignore if NULL parameter present on list' do
    list = [1,nil,3]
    expected = list.reject{ |e| e.nil? }
    result = decode_bitmap( encode_bitmap( list ) )
    result.should == expected
  end

  it 'should decode encoded bitmap to a list ' do
    list = (1..1400).to_a
    expected = list.reject{ |e| e.nil? }
    result = decode_bitmap( encode_bitmap( list ) )
    result.should == expected
  end

  it 'should deoode a bitmap into a valid list' do
    bmap=[[17],[1],[1],[1],[1]]
    expected = [1,5]
    decode_bitmap( bmap ).should==expected
  end

  it 'should decode bitmap with last segment set ' do
    expected = ( ((@max_bit_number-(@bits_in_segment-1))..@max_bit_number).to_a )
    result = encode_and_decode_bitmap( expected  )
    result.should == expected

  end

end
