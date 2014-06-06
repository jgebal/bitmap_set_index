require_relative '../spec_helper'

describe 'should save bitmap list to bitmap table' do

  it 'should save record to table' do
    cnt = plsql.hierarchical_bitmap_table.select(:count)

    bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([1])
    plsql.BMAP_UTIL.saveBitmapLst(bmap_value)

    result = plsql.hierarchical_bitmap_table.select(:count)

    result.should == cnt + 1
  end

  it 'should return 0 bitmap key if bitmap list is empty' do
    bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([])
    plsql.BMAP_UTIL.saveBitmapLst(bmap_value).should == 0
  end

  it 'should return 0 bitmap key null' do
    plsql.BMAP_UTIL.saveBitmapLst(nil).should == 0
  end
end