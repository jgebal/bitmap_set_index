require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should save bitmap list to bitmap table' do

  include_context 'shared bitmap builder'

  it 'should save record to table' do
    cnt = plsql.hierarchical_bitmap_table.select(:count)

    bmap_value = [1]
    encode_and_insert_bitmap(bmap_value)

    result = plsql.hierarchical_bitmap_table.select(:count)

    expect(result).to eq(cnt + 1)
  end

  it 'should return 0 bitmap key if bitmap list is empty' do
    expect(encode_and_insert_bitmap([])).to eq(0)
  end

  it 'should return 0 bitmap key null' do
    expect(encode_and_insert_bitmap(nil)).to eq(0)
  end
end