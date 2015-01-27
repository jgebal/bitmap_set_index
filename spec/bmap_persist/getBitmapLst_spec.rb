require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'get bitmap list from bitmap table for given bitmap key' do

  include_context 'shared bitmap builder'

  it 'should return not empty record' do
    bitmap = [1,2,3,4,5,6,7,8,123,124,125,12345]
    bitmap_key =  encode_and_insert_bmap(bitmap)

    result = select_and_decode_bmap(bitmap_key)

    expect(result).to eq(bitmap)
  end

  it 'should return null if bmap_key is null' do

    result = select_and_decode_bmap(nil)

    expect(result).to eq([])
  end

  it 'should return null if bmap_key not exists' do
    bitmap_key = plsql.select_one('select NVL(max(bitmap_key), 0) from hierarchical_bitmap_table')

    expect(select_and_decode_bmap(bitmap_key+1)).to eq([])
  end
end
