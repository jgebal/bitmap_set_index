require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should save bitmap list to bitmap table' do

  it 'should save record to table' do
    cnt = plsql.hierarchical_bitmap_table.select(:count)

    bmap_value = encode_bitmap(1)
    plsql.bmap_persist.insertBitmapLst(bmap_value)

    result = plsql.hierarchical_bitmap_table.select(:count)

    expect(result).to eq( cnt + 1 )
  end

  it 'should return 0 bitmap key if bitmap list is empty' do
    bmap_value = encode_bitmap(nil)
    expect( plsql.bmap_persist.insertBitmapLst(bmap_value) ).to eq( 0 )
  end

  it 'should return 0 bitmap key null' do
    expect( plsql.bmap_persist.insertBitmapLst(nil) ).to eq( 0 )
  end
end