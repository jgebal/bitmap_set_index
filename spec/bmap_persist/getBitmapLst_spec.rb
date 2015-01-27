require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should get bitmap list from bitmap table for given bitmap key' do

  include_context 'shared bitmap builder'

  it 'should return not empty record' do
    bitmap = [1,2,3,4,5,6,7,8,123,124,125,12345]
    bitmap_key =  encode_and_insert_bitmap(bitmap)

    result = select_and_decode_bitmap(bitmap_key)

    result.should == bitmap
  end

  it 'should return null if bmap_key is null' do

    result = select_and_decode_bitmap(nil)

    result.should ==[]
  end

  it 'should return null if bmap_key not exists' do
    bitmap_key = plsql.select_one('select NVL(max(bitmap_key), 0) from hierarchical_bitmap_table')

    select_and_decode_bitmap(bitmap_key+1).should ==[]
  end
end
