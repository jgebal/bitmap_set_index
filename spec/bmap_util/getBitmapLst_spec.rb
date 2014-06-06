require_relative '../spec_helper'

describe 'should get bitmap list from bitmap table for given bitmap key' do

  it 'should return not empty record' do
    bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([1])
    bitmap_key =  plsql.BMAP_UTIL.saveBitmapLst(bmap_value)

    result = plsql.BMAP_UTIL.getBitmapLst(bitmap_key)

    result.should == [[1], [1], [1], [1], [1]]
  end

  it 'should return null if bmap_key is null' do

    result = plsql.BMAP_UTIL.getBitmapLst(nil)

    result.should be_nil
  end

  it 'should return null if bmap_key not exists' do
    bitmap_key = plsql.select_one('select nvl(max(bitmap_key),0) from hierarchical_bitmap_table')

    plsql.BMAP_UTIL.getBitmapLst(bitmap_key+1).should be_nil
  end
end
