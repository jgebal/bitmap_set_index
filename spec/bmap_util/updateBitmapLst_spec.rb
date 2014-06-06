require_relative '../spec_helper'

describe 'should update bitmap list to bitmap table' do
  before(:each) do
    @bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([1])
  end

  it 'should update record to table' do
    keyid = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)

    plsql.BMAP_UTIL.updateBitmapLst(keyid, @bmap_value).should == 1
  end

  it 'should update not existing key' do
    plsql.BMAP_UTIL.updateBitmapLst(0, @bmap_value).should == 0
  end

  it 'should not update records when bitmap key is null' do
    plsql.BMAP_UTIL.updateBitmapLst(nil, @bmap_value).should == 0
  end

  it 'should return -1 when bitmap list is null' do
    keyid = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)

    plsql.BMAP_UTIL.updateBitmapLst(keyid, nil).should == -1
  end

  it 'should return -1 when bitmap list is empty' do
    keyid = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)

    plsql.BMAP_UTIL.updateBitmapLst(keyid, plsql.bmap_util.bit_no_lst_to_bit_map([])).should == -1
  end

  it 'should modify bitmap in bitmap table' do
    keyid = plsql.BMAP_UTIL.insertBitmapLst(@bmap_value)
    tmp_bmap_value = plsql.bmap_util.bit_no_lst_to_bit_map([5])

    plsql.BMAP_UTIL.updateBitmapLst(keyid, tmp_bmap_value)

    plsql.BMAP_UTIL.getBitmapLst(keyid).should == tmp_bmap_value
  end
end