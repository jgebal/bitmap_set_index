def encode_bitmap(*bit_number_list)
  if bit_number_list.is_a?(Array) && bit_number_list[0].is_a?(Array) then
    plsql.bmap_builder.encode_bitmap(bit_number_list[0])
  else
    plsql.bmap_builder.encode_bitmap(bit_number_list)
  end
end

def decode_bitmap(bitmap)
  plsql.bmap_builder.decode_bitmap(bitmap)
end

def set_bit_in_segment(bit,segment)
  @bits_in_segment*(segment-1)+bit
end

def bit_and(left, right)
  plsql.bmap_operator.bit_and(left, right)
end