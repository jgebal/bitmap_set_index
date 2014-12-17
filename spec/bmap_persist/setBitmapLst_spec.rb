require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should set bitmap list for given bitmap key' do
  before(:each) do
    @bmap_value = encode_bitmap(1)
  end

  it 'should insert new record if bitmap key is null' do
    bitmap_key = nil
    affectedRows = nil

    plsql.bmap_persist.setBitmapLst(bitmap_key, @bmap_value, affectedRows).should == { :pi_bitmap_key => plsql.hierarchical_bitmap_key.currval, :pio_affected_rows => nil }
  end

  it 'should update existing record if bitmap key is given' do
    bitmap_key = plsql.bmap_persist.insertBitmapLst(@bmap_value)
    rowsCount = plsql.hierarchical_bitmap_table.select(:count)

    tmp_bmap_value = encode_bitmap(5)

    plsql.bmap_persist.setBitmapLst(bitmap_key, tmp_bmap_value, nil).should == { :pi_bitmap_key => bitmap_key, :pio_affected_rows => 1 }

    plsql.bmap_persist.getBitmapLst(bitmap_key).should == tmp_bmap_value

    resultRowsCount = plsql.hierarchical_bitmap_table.select(:count)

    resultRowsCount.should == rowsCount
  end

  [
    encode_bitmap(nil), nil
  ].each do |bitmap|
    it "should delete record if bitmap list is #{bitmap.nil? ? 'null' : 'empty'} for existing bitmap key" do
      bitmap_key = plsql.bmap_persist.insertBitmapLst(@bmap_value)
      rowsCount = plsql.hierarchical_bitmap_table.select(:count)

      plsql.bmap_persist.setBitmapLst(bitmap_key, bitmap, nil).should == { :pi_bitmap_key => bitmap_key, :pio_affected_rows => 1 }

      plsql.bmap_persist.getBitmapLst(bitmap_key).should be_nil

      resultRowsCount = plsql.hierarchical_bitmap_table.select(:count)

      resultRowsCount.should == rowsCount - 1
    end
  end

end
