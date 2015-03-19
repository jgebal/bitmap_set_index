require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should get bitmap list from bitmap table for given bitmap key' do

  it 'should return not empty record' do
    bmap_value = encode_bitmap(1)
    bitmap_key =  plsql.bmap_persist.insertBitmapLst(bmap_value)

    result = plsql.bmap_persist.getBitmapLst(bitmap_key)

    expect( result).to eq( [[1], [1], [1], [1], [1]] )
  end

  it 'should return null if bmap_key is null' do

    result = plsql.bmap_persist.getBitmapLst(nil)

    expect( result ).to be_nil
  end

  it 'should return null if bmap_key not exists' do
    bitmap_key = plsql.select_one('select NVL(max(bitmap_key), 0) from hierarchical_bitmap_table')

    expect( plsql.bmap_persist.getBitmapLst(bitmap_key+1) ).to be_nil
  end
end
