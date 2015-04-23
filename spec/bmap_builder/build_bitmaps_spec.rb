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
  def get_bmap_root_segment(table_name, key)
    get_segment(table_name, key, 1, 3)
  end

  it 'should save a valid set of segments into given table' do
    #given
    bitmap_key = 1
    bit_list = (1..27000).to_a
    max_node_value = 2**30 - 1
    expected_root_bitmap = [
        [{node_index: 1, node_value:1}],
        [{node_index: 1, node_value:1}],
        [{node_index: 1, node_value:1}]
    ]
    full_bitmap_segment = [
        Array.new(900){ |i| ({node_index: i+1, node_value:max_node_value}).to_s },
        Array.new(30){ |i| ({node_index: i+1, node_value:max_node_value}).to_s },
        [{node_index: 1, node_value:max_node_value}]
    ]
    #when
    build_bitmap( storage_table_name, bitmap_key, bit_list )
    #then
    expect( get_bmap_root_segment( storage_table_name, bitmap_key) ).to eq(expected_root_bitmap)
    expect( get_segment( storage_table_name, bitmap_key, 1,1) ).to eq(full_bitmap_segment)

    # expect(result_bmap.size).to eq(4)
    # result_bmap.each do |level|
    #   level.each_index do |position|
    #     expect(level[position][:node_index]).to eq(position+1)
    #     expect(level[position][:node_value]).to eq expected_bitmap_node_value
    #   end
    # end
  end

  after(:all) do

  end

end