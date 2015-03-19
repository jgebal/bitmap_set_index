require_relative '../spec_helper'

describe 'should update bitmap list to bitmap table' do
  before(:each) do
    @bmap_value = plsql.bmap_persist.bit_no_lst_to_bit_map([1])
  end

  it 'should update record to table' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)

    expect( plsql.bmap_persist.updateBitmapLst(keyid, @bmap_value) ).to eq( 1 )
  end

  it 'should update not existing key' do
    expect( plsql.bmap_persist.updateBitmapLst(0, @bmap_value) ).to eq( 0 )
  end

  it 'should not update records when bitmap key is null' do
    expect( plsql.bmap_persist.updateBitmapLst(nil, @bmap_value) ).to eq( 0 )
  end

  it 'should return -1 when bitmap list is null' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)

    expect( plsql.bmap_persist.updateBitmapLst(keyid, nil) ).to eq( -1 )
  end

  it 'should return -1 when bitmap list is empty' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)

    expect( plsql.bmap_persist.updateBitmapLst(keyid, plsql.bmap_persist.bit_no_lst_to_bit_map([])) ).to eq( -1 )
  end

  it 'should modify bitmap in bitmap table' do
    keyid = plsql.bmap_persist.insertBitmapLst(@bmap_value)
    tmp_bmap_value = plsql.bmap_persist.bit_no_lst_to_bit_map([5])

    plsql.bmap_persist.updateBitmapLst(keyid, tmp_bmap_value)

    expect( plsql.bmap_persist.getBitmapLst(keyid) ).to eq( tmp_bmap_value )
  end
end