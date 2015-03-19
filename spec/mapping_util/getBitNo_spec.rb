require_relative '../spec_helper'

describe 'should return bitmap number for given business key list' do

  it 'should return null if key list is null' do
    expect( plsql.mapping_util.getBitNo(nil) ).to be_nil
  end

  it 'should return null if key list is empty' do
    key_list = plsql.select_one('select MAPPING_KEY_LIST() from dual')

    expect( plsql.mapping_util.getBitNo(key_list) ).to be_nil
  end

  it 'should return bitmap number if key list exists' do
    key_list = plsql.select_one('select MAPPING_KEY_LIST(10,20,30) from dual')
    expected_bit_no = plsql.bitmap_mapping_table.select(:count) + 1
    plsql.bitmap_mapping_table.insert({bit_no: expected_bit_no, mapping_node:key_list})

    expect( plsql.mapping_util.getBitNo(key_list) ).to eq( expected_bit_no )
  end

  it 'should insert mapping record if key list not exists' do
    key_list = plsql.select_one('select MAPPING_KEY_LIST(10,20,30) from dual')
    expected_bit_no = plsql.bitmap_mapping_table.select(:count) + 1
    expect( plsql.mapping_util.getBitNo(key_list) ).to eq( expected_bit_no )
  end

  it 'should remove NULLs from key list while mapping to bit number' do
    key_list = plsql.select_one('select MAPPING_KEY_LIST(10,20,30) from dual')
    expected_bit_no = plsql.bitmap_mapping_table.select(:count) + 1
    plsql.bitmap_mapping_table.insert({bit_no: expected_bit_no, mapping_node:key_list})
    new_key_list = plsql.select_one('select MAPPING_KEY_LIST(NULL, 10,20,NULL, 30) from dual')
    expect( plsql.mapping_util.getBitNo(new_key_list) ).to eq( expected_bit_no )
  end
end
