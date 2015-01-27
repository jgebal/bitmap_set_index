require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should delete bitmap list from bitmap table' do

  include_context 'shared bitmap builder'

  before(:all) do
    @bmap_values_to_encode = [1,2,3,4,5,6,7,8,123,124,125]
  end

  it 'should delete only one record from table' do
    encode_and_insert_bmap(@bmap_values_to_encode)
    keyid = encode_and_insert_bmap(@bmap_values_to_encode)
    row_count = plsql.hierarchical_bitmap_table.count
    expect( plsql.bmap_persist.deleteBitmapLst(keyid) ).to eq  1
    expect( plsql.hierarchical_bitmap_table.count ).to eq row_count - 1
  end

  it 'should not delete if key does not exists' do
    expected = plsql.hierarchical_bitmap_table.count
    expect( plsql.bmap_persist.deleteBitmapLst(0) ).to eq 0
    expect( plsql.hierarchical_bitmap_table.count ).to eq expected
  end

  it 'should delete record from table' do
    keyid = encode_and_insert_bmap(@bmap_values_to_encode)

    rows_count = plsql.hierarchical_bitmap_table.select(:count)

    plsql.bmap_persist.deleteBitmapLst(keyid)
    expect( plsql.hierarchical_bitmap_table.select(:count) ).to eq rows_count-1
  end

end