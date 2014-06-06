require_relative '../spec_helper'

describe 'should delete bitmap list from bitmap table' do
  before(:each) do
    @bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([1])
  end

  it 'should delete only one record from table' do
    keyid = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)

    plsql.BMAP_UTIL.deleteBitmapLst(keyid).should == 1
  end

  it 'should not delete if key does not exists' do
    plsql.BMAP_UTIL.deleteBitmapLst(0).should == 0
  end

  it 'should delete record from table' do
    keyid = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)

    rowsCount = plsql.hierarchical_bitmap_table.select(:count)

    plsql.BMAP_UTIL.deleteBitmapLst(keyid)
    plsql.hierarchical_bitmap_table.select(:count).should == rowsCount-1
  end

end