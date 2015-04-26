require_relative '../spec_helper'
require_relative '../helpers/bmap_storage_helper'

describe 'Build and store bitmap index' do

  include_context 'shared bitmap storage'

  def one_bit_bitmap_segment
    [
        [{node_index: 1, node_value:1}],
        [{node_index: 1, node_value:1}],
        [{node_index: 1, node_value:1}]
    ]
  end
  def full_bitmap_segment
    max_node_value = 2**30 - 1
    [
        Array.new(900){ |i| {node_index: i+1, node_value:max_node_value} },
        Array.new(30){  |i| {node_index: i+1, node_value:max_node_value} },
        [{node_index: 1, node_value:max_node_value}]
    ]
  end

  it 'should save a valid set of segments into given table' do
    #given
    bitmap_key = 1
    bit_list = (1..54000).to_a
    two_bit_segment = [
        [{node_index: 1, node_value: 2**0 + 2**1}],
        [{node_index: 1, node_value: 1}],
        [{node_index: 1, node_value: 1}]
    ]
    #when
    build_bitmap( storage_table_name, bitmap_key, bit_list )
    #then

    expect( get_segment( storage_table_name, bitmap_key, 1, 3) ).to eq( one_bit_bitmap_segment )
    expect( get_segment( storage_table_name, bitmap_key, 1, 2) ).to eq( two_bit_segment )
    expect( get_segment( storage_table_name, bitmap_key, 2, 1) ).to eq( full_bitmap_segment )
    expect( get_segment( storage_table_name, bitmap_key, 1, 1) ).to eq( full_bitmap_segment )

    expect( count_segments( storage_table_name, bitmap_key) ).to eq(4)

  end

  it 'should create a bitmap for a single bit' do
    bitmap_key = 1
    bit_list = [plsql.bmap_builder.c_max_bitmap_size]
    last_bit_set_segment = [
        [{node_index: 900, node_value: 2**29}],
        [{node_index:  30, node_value: 2**29}],
        [{node_index:   1, node_value: 2**29}]
    ]
    build_bitmap( storage_table_name, bitmap_key, bit_list )
    expect( get_segment( storage_table_name, bitmap_key, 1, 3) ).to eq( last_bit_set_segment )
    expect( get_segment( storage_table_name, bitmap_key, 27000, 2) ).to eq( last_bit_set_segment )
    expect( get_segment( storage_table_name, bitmap_key, 27000**2, 1) ).to eq( last_bit_set_segment )

    expect( count_segments( storage_table_name, bitmap_key) ).to eq(3)

  end

  it 'should create a bitmap for a maximum allowed value of bit pos' do
    bitmap_key = 1
    bit_list = [1]
    first_bit_set_segment = [
        [{node_index: 1, node_value: 1}],
        [{node_index: 1, node_value: 1}],
        [{node_index: 1, node_value: 1}]
    ]
    build_bitmap( storage_table_name, bitmap_key, bit_list )
    expect( get_segment( storage_table_name, bitmap_key, 1, 3) ).to eq( first_bit_set_segment )
    expect( get_segment( storage_table_name, bitmap_key, 1, 2) ).to eq( first_bit_set_segment )
    expect( get_segment( storage_table_name, bitmap_key, 1, 1) ).to eq( first_bit_set_segment )

    expect( count_segments( storage_table_name, bitmap_key) ).to eq(3)

  end

end