require_relative '../spec_helper'

describe 'should delete bitmap list from bitmap table' do
  before(:each) do
    @bmap_value = encode_bitmap(1)
  end

  it 'should delete only one record from table' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)

    plsql.bmap_persist.deleteBitmapLst(keyid).should == 1
  end

  it 'should not delete if key does not exists' do
    plsql.bmap_persist.deleteBitmapLst(0).should == 0
  end

  it 'should delete record from table' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)

    rowsCount = plsql.hierarchical_bitmap_table.select(:count)

    plsql.bmap_persist.deleteBitmapLst(keyid)
    plsql.hierarchical_bitmap_table.select(:count).should == rowsCount-1
  end

end