require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should delete bitmap list from bitmap table' do

  include_context 'shared bitmap builder'

  before(:all) do
    @bmap_value = [1,2,3,4,5,6,7,8,123,124,125]
  end

  it 'should delete only one record from table' do
    encode_and_insert_bitmap(@bmap_value)
    keyid = encode_and_insert_bitmap(@bmap_value)
    row_count = plsql.hierarchical_bitmap_table.count

    plsql.bmap_persist.deleteBitmapLst(keyid).should == 1
    plsql.hierarchical_bitmap_table.count.should == row_count - 1
  end

  it 'should not delete if key does not exists' do
    expected = plsql.hierarchical_bitmap_table.count
    plsql.bmap_persist.deleteBitmapLst(0).should == 0
    plsql.hierarchical_bitmap_table.count.should == expected
  end

  it 'should delete record from table' do
    keyid = encode_and_insert_bitmap(@bmap_value)

    rows_count = plsql.hierarchical_bitmap_table.select(:count)

    plsql.bmap_persist.deleteBitmapLst(keyid)
    plsql.hierarchical_bitmap_table.select(:count).should == rows_count-1
  end

end