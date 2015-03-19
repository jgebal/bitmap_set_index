require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should delete bitmap list from bitmap table' do
  before(:each) do
    @bmap_value = encode_bitmap(1)
  end

  it 'should delete only one record from table' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)

    expect( plsql.bmap_persist.deleteBitmapLst(keyid) ).to eq( 1 )
  end

  it 'should not delete if key does not exists' do
    expect( plsql.bmap_persist.deleteBitmapLst(0) ).to eq( 0 )
  end

  it 'should delete record from table' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)

    rowsCount = plsql.hierarchical_bitmap_table.select(:count)

    plsql.bmap_persist.deleteBitmapLst(keyid)
    expect( plsql.hierarchical_bitmap_table.select(:count) ).to eq( rowsCount-1 )
  end

end