require_relative '../spec_helper'
require_relative '../helpers/bmap_storage_helper'
require_relative '../helpers/bmap_helpers'

describe 'Insert bitmap segment' do

  include_context 'shared bitmap storage'
  include_context 'shared bitmap builder'

  it 'should save a segment into given table' do
    #given
    bitmap_key = 1
    bitmap_segment_h_pos = 1
    bitmap_segment_v_pos = 1
    bit_list = [1,2,3,4]
    expect(plsql.select_one("select count(1) from #{storage_table_name}")).to eq 0
    #when
    encode_and_insert_segment( storage_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )
    #then
    expect(plsql.select_one("select count(1) from #{storage_table_name}")).to eq 1
  end

  it 'should save a segment with valid values in single element' do
    #given
    bitmap_key = 1
    bitmap_segment_h_pos = 1
    bitmap_segment_v_pos = 1
    bit_list = [1,2,3,4]
    segment_element_value = bit_list.map{|bit_no| 2**(bit_no-1)}.inject(:+)
    expected_bitmap = [
        [{node_index: 1, node_value:segment_element_value}],
        [{node_index: 1, node_value: 1}],
        [{node_index: 1, node_value: 1}]
    ]
    #when
    encode_and_insert_segment( storage_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )
    #then
    expect(plsql.select_one("select bmap from #{storage_table_name}")).to eq expected_bitmap
  end

  it 'should save a segment with valid values in multiple elements' do
    #given
    bitmap_key = 1
    bitmap_segment_h_pos = 1
    bitmap_segment_v_pos = 1
    bit_list = [1,2,3,4,27000]
    expected_bitmap = [
        [{node_index: 1,     node_value: 2**0 + 2**1 + 2**2 + 2**3},
         {node_index: 30**2, node_value: 2**29}
        ],
        [{node_index: 1,     node_value: 1},
         {node_index: 30**1, node_value: 2**29}
        ],
        [{node_index: 1,     node_value: 2**0 + 2**29}
        ]
    ]
    #when
    encode_and_insert_segment( storage_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )
    #then
    expect(plsql.select_one("select bmap from #{storage_table_name}")).to eq expected_bitmap
  end

  it 'should save a completely filled segment' do
    #given
    bitmap_key = 1
    bitmap_segment_h_pos = 1
    bitmap_segment_v_pos = 1
    bit_list = (1..27000).to_a
    max_node_value = 2**30 - 1
    full_bitmap_segment = [
        Array.new(900){ |i| {node_index: i+1, node_value:max_node_value} },
        Array.new(30){  |i| {node_index: i+1, node_value:max_node_value} },
        [{node_index: 1, node_value:max_node_value}]
    ]

    #when
    encode_and_insert_segment( storage_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )

    #then
    result_bmap = plsql.select_one("select bmap from #{storage_table_name}")
    expect(result_bmap).to eq(full_bitmap_segment)
    expect(result_bmap[0].size).to eq(900)
    expect(result_bmap[1].size).to eq(30)
    expect(result_bmap[2].size).to eq(1)
    result_bmap.each do |level|
      level.each_index do |position|
        expect(level[position][:node_index]).to eq(position+1)
        expect(level[position][:node_value]).to eq max_node_value
      end
    end

  end

end