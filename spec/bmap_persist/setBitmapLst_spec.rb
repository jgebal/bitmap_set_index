require_relative '../spec_helper'
require_relative '../helpers/bmap_helpers'

describe 'should set bitmap list for given bitmap key' do

  include_context 'shared bitmap builder'

  before(:each) do
    @bmap_values_to_encode = [1]
  end

  it 'should insert new record if bitmap key is null' do
    bitmap_key = nil
    rows_count = plsql.hierarchical_bitmap_table.select(:count)
    expect(
        encode_and_set_bitmap(bitmap_key, @bmap_values_to_encode)
    ).to eq [nil, :pio_bitmap_key => plsql.hierarchical_bitmap_key.currval ]

    expect( plsql.hierarchical_bitmap_table.select(:count) ).to eq rows_count + 1
  end

  it 'should update existing record if bitmap key is given' do
    bitmap_key = encode_and_insert_bitmap(@bmap_values_to_encode)
    rows_count = plsql.hierarchical_bitmap_table.select(:count)

    tmp_bmap_value = [5]

    encode_and_set_bitmap(bitmap_key, tmp_bmap_value).should == [1, {:pio_bitmap_key => bitmap_key} ]

    select_and_decode_bitmap(bitmap_key).should == tmp_bmap_value

    result_rows_count = plsql.hierarchical_bitmap_table.select(:count)

    result_rows_count.should == rows_count
  end

  it 'should delete record if bitmap list is NULL or empty for existing bitmap key' do
    [ [], nil ].each do |bitmap|
      bitmap_key = encode_and_insert_bitmap(@bmap_values_to_encode)
      rows_count = plsql.hierarchical_bitmap_table.select(:count)

      encode_and_set_bitmap(bitmap_key, bitmap).should == [1, { :pio_bitmap_key => bitmap_key }]

      select_and_decode_bitmap(bitmap_key).should == []

      result_rows_count = plsql.hierarchical_bitmap_table.select(:count)

      result_rows_count.should == rows_count - 1
    end
  end

end
