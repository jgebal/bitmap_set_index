require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Add bit list to a bitmap' do

  include_context 'shared bitmap builder'

  it 'should return empty bitmap when empty bitmap and bit list passed' do
    bit_list = nil
    bit_map = nil
    add_bit_list_to_bitmap(bit_list,bit_map).should == []
  end

  it 'should return the input bitmap when empty bit list passed' do
    bit_list = nil
    bit_map = [1,2,3,4,12134234,54353,5345]
    add_bit_list_to_bitmap(bit_list,bit_map).should =~ bit_map
  end

  it 'should return a new bitmap created from bit list when empty bit map passed' do
    bit_list = [1,2,3,4,12134234,54353,5345]
    bit_map = nil
    add_bit_list_to_bitmap(bit_list,bit_map).should =~ bit_list
  end

  it 'should return a bitmap with new bits encoded from bit list when non empty bit map passed' do
    bit_list = [1,2,3,4,12134234,54353,5345]
    bit_map = [1,2,3,4]
    add_bit_list_to_bitmap(bit_list,bit_map).should =~ (bit_list+bit_map).uniq
  end

end