RSpec.shared_context 'shared bitmap builder' do

  before(:all) do
    plsql.dbms_output_stream = STDOUT
    @bits_in_segment = plsql.bmap_builder.get_index_length
    @max_bit_number = plsql.bmap_builder.c_max_bits
    plsql.execute(
        <<-SQL
      CREATE OR REPLACE FUNCTION encode_decode_test(pt_bit_numbers_list INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bitmap( bmap_builder.encode_bitmap( pt_bit_numbers_list ) );
      END;
    SQL
    )
    plsql.execute(
        <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitand_test(pt_left INT_LIST, pt_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bitmap(
                 bmap_builder.bit_and(
                   bmap_builder.encode_bitmap( pt_left ),
                   bmap_builder.encode_bitmap( pt_right )
                 )
               );
      END;
    SQL
    )
    plsql.execute(
        <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitor_test(pt_left INT_LIST, pt_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bitmap(
                 bmap_builder.bit_or(
                   bmap_builder.encode_bitmap( pt_left ),
                   bmap_builder.encode_bitmap( pt_right )
                 )
               );
      END;
    SQL
    )
    plsql.execute(
        <<-SQL
      CREATE OR REPLACE FUNCTION add_bit_list_to_bitmap_test(pt_bit_numbers_list INT_LIST, pt_bit_map_to_build INT_LIST) RETURN INT_LIST IS
        bit_map bmap_builder.BMAP_LEVEL_LIST;
      BEGIN
        bit_map := bmap_builder.encode_bitmap( pt_bit_map_to_build );
        bmap_builder.add_bit_list_to_bitmap( pt_bit_numbers_list, bit_map );
        RETURN bmap_builder.decode_bitmap( bit_map );
      END;
    SQL
    )
    plsql.execute(
        <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitminus_test(pt_left INT_LIST, pt_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bitmap(
                 bmap_builder.bit_minus(
                   bmap_builder.encode_bitmap( pt_left ),
                   bmap_builder.encode_bitmap( pt_right )
                 )
               );
      END;
    SQL
    )
  end

  after(:all) do
    plsql.execute('DROP FUNCTION encode_decode_test;')
    plsql.execute('DROP FUNCTION encode_bitand_test;')
    plsql.execute('DROP FUNCTION encode_bitor_test;')
    plsql.execute('DROP FUNCTION add_bit_list_to_bitmap_test;')
    plsql.execute('DROP FUNCTION encode_bitminus_test;')
  end

  def encode_and_decode_bitmap(bit_number_list)
    plsql.encode_decode_test(bit_number_list)
  end

  def bit_and( left, right )
    plsql.encode_bitand_test(left, right)
  end

  def bit_minus( left, right )
    plsql.encode_bitminus_test(left, right)
  end

  def bit_or( left, right )
    plsql.encode_bitor_test(left, right)
  end

  def add_bit_list_to_bitmap(bit_list, bit_map)
    plsql.add_bit_list_to_bitmap_test(bit_list, bit_map)
  end

end

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
