require_relative '../spec_helper'

describe 'should set bitmap list for given bitmap key' do
  before(:each) do
    @bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([1])
  end

  it 'should insert new record if bitmap key is null' do
    bitmap_key = nil
    affectedRows = nil

    plsql.BMAP_UTIL.setBitmapLst(bitmap_key, @bmap_value, affectedRows).should == { :pi_bitmap_key => plsql.hierarchical_bitmap_key.currval, :pio_affected_rows => nil }
  end

  it 'should update existing record if bitmap key is given' do
    bitmap_key = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)
    rowsCount = plsql.hierarchical_bitmap_table.select(:count)

    tmp_bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([5])

    plsql.BMAP_UTIL.setBitmapLst(bitmap_key, tmp_bmap_value, nil).should == { :pi_bitmap_key => bitmap_key, :pio_affected_rows => 1 }

    plsql.BMAP_UTIL.getBitmapLst(bitmap_key).should == tmp_bmap_value

    resultRowsCount = plsql.hierarchical_bitmap_table.select(:count)

    resultRowsCount.should == rowsCount
  end

  [
    plsql.bmap_util.bit_no_lst_to_bit_map([]), nil
  ].each do |bitmap|
    it "should delete record if bitmap list is #{bitmap.nil? ? 'null' : 'empty'} for existing bitmap key" do
      bitmap_key = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)
      rowsCount = plsql.hierarchical_bitmap_table.select(:count)

      plsql.BMAP_UTIL.setBitmapLst(bitmap_key, bitmap, nil).should == { :pi_bitmap_key => bitmap_key, :pio_affected_rows => 1 }

      plsql.BMAP_UTIL.getBitmapLst(bitmap_key).should be_nil

      resultRowsCount = plsql.hierarchical_bitmap_table.select(:count)

      resultRowsCount.should == rowsCount - 1
    end
  end

end
