require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'Insert bitmap segment' do

  include_context 'shared bitmap builder'

  before(:all) do
    @p_stor_table_name = 'test_bitmap_segments'
    plsql.execute "CREATE TABLE  #{@p_stor_table_name}(
            BITMAP_KEY NUMBER(6,0),
            BMAP_V_POS INTEGER,
            BMAP_H_POS INTEGER,
            BMAP       STOR_BMAP_SEGMENT)"
  end

  it 'should save a segment into given table' do
    #given
    bitmap_key = 1
    bitmap_segment_h_pos = 1
    bitmap_segment_v_pos = 1
    bit_list = [1,2,3,4]
    expect(plsql.select_one("select count(1) from #{@p_stor_table_name}")).to eq 0
    #when
    encode_and_insert_segment( @p_stor_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )
    #then
    expect(plsql.select_one("select count(1) from #{@p_stor_table_name}")).to eq 1
  end

  it 'should save a segment with valid values in single element' do
    #given
    bitmap_key = 1
    bitmap_segment_h_pos = 1
    bitmap_segment_v_pos = 1
    bit_list = [1,2,3,4]
    segment_element_value = bit_list.map{|bit_no| 2**(bit_no-1)}.inject(:+)
    expected_bitmap = [
        [{node_index: 1, :node_value=>segment_element_value}],
        [{:node_index=>1, :node_value=>1}],
        [{:node_index=>1, :node_value=>1}]
    ]
    #when
    encode_and_insert_segment( @p_stor_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )
    #then
    expect(plsql.select_one("select bmap from #{@p_stor_table_name}")).to eq expected_bitmap
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
    encode_and_insert_segment( @p_stor_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )
    #then
    expect(plsql.select_one("select bmap from #{@p_stor_table_name}")).to eq expected_bitmap
  end

  it 'should save a completely filled segment' do
    #given
    bitmap_key = 1
    bitmap_segment_h_pos = 1
    bitmap_segment_v_pos = 1
    bit_list = (1..27000).to_a
    expected_bitmap_node_value = 2**30 - 1
    #when
    encode_and_insert_segment( @p_stor_table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_list )
    #then
    result_bmap = plsql.select_one("select bmap from #{@p_stor_table_name}")
    result_bmap.each do |level|
      expect([900,30,1]).to include(level.count)
      level.each_index do |position|
        expect(level[position][:node_index]).to eq(position+1)
        expect(level[position][:node_value]).to eq expected_bitmap_node_value
      end
    end

  end

  after(:all) do
    plsql.execute 'DROP TABLE test_bitmap_segments'
  end

end