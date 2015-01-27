require_relative '../spec_helper'

describe 'should update bitmap list to bitmap table' do

  include_context 'shared bitmap builder'

  before(:each) do
    @bmap_values_to_encode = [1]
  end

  it 'should update record to table' do
    key_id = encode_and_insert_bitmap(@bmap_values_to_encode)

    expect(encode_and_update_bitmap(key_id, @bmap_values_to_encode)).to eq(1)
  end

  it 'should update not existing key' do
    expect(encode_and_update_bitmap(0, @bmap_values_to_encode)).to eq(0)
  end

  it 'should not update records when bitmap key is null' do
    expect(encode_and_update_bitmap(nil, @bmap_values_to_encode)).to eq(0)
  end

  it 'should return -1 when bitmap list is null' do
    key_id = encode_and_insert_bitmap(@bmap_values_to_encode)

    expect(encode_and_update_bitmap(key_id, nil)).to eq(-1)
  end

  it 'should return -1 when bitmap list is empty' do
    key_id = encode_and_insert_bitmap(@bmap_values_to_encode)

    expect(encode_and_update_bitmap(key_id, [])).to eq(-1)
  end

  it 'should modify bitmap in bitmap table' do
    key_id = encode_and_insert_bitmap(@bmap_values_to_encode)
    tmp_bmap_value = [5]

    encode_and_update_bitmap(key_id, tmp_bmap_value)

    expect(select_and_decode_bitmap(key_id)).to eq(tmp_bmap_value)
  end
end