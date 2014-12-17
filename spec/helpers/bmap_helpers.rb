def encode_bitmap(*bit_number)
  plsql.bmap_builder.encode_bitmap(bit_number)
end
def set_bit_in_segment(bit,segment)
  @bits_in_segment*(segment-1)+bit
end

