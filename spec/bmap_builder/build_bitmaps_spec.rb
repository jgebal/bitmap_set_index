require_relative '../spec_helper'
require_relative '../helpers/bmap_storage_helper'

describe 'Build and store bitmap index' do

  include_context 'shared bitmap storage'

  def get_segment(table_name, key, h_pos, v_pos)
    sql = <<-SQL
    SELECT bmap FROM #{table_name}
     WHERE bitmap_key = :key
      AND bmap_h_pos = :h_pos
      AND bmap_v_pos = :v_pos
    SQL
    plsql.select_one(sql, key, h_pos, v_pos)
  end

  def count_segments(table_name, key)
    sql = <<-SQL
    SELECT COUNT(1) FROM #{table_name}
     WHERE bitmap_key = :key
    SQL
    plsql.select_one(sql, key)
  end

  def get_bmap_root_segment(table_name, key)
    get_segment(table_name, key, 1, 3)
  end

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

    expect( get_bmap_root_segment( storage_table_name, bitmap_key) ).to eq( one_bit_bitmap_segment )
    expect( get_segment( storage_table_name, bitmap_key, 1, 2 ) ).to eq( two_bit_segment )
    expect( get_segment( storage_table_name, bitmap_key, 2,1) ).to eq( full_bitmap_segment )
    expect( get_segment( storage_table_name, bitmap_key, 1,1) ).to eq( full_bitmap_segment )

    expect( count_segments( storage_table_name, bitmap_key) ).to eq(4)

  end

  after(:all) do

  end

end