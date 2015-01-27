RSpec.shared_context 'shared bitmap builder' do

  before(:all) do
    plsql.dbms_output_stream = STDOUT
    @bits_in_segment = plsql.bmap_builder.C_ELEMENT_CAPACITY
    @max_bit_number = plsql.bmap_builder.C_SEGMENT_CAPACITY
    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_decode_test(pt_bit_numbers_list INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bmap_segment( bmap_builder.encode_bmap_segment( pt_bit_numbers_list ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitand_test(pt_left INT_LIST, pt_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bmap_segment(
                 bmap_builder.segment_bit_and(
                   bmap_builder.encode_bmap_segment( pt_left ),
                   bmap_builder.encode_bmap_segment( pt_right )
                 )
               );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitor_test(pt_left INT_LIST, pt_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bmap_segment(
                 bmap_builder.segment_bit_or(
                   bmap_builder.encode_bmap_segment( pt_left ),
                   bmap_builder.encode_bmap_segment( pt_right )
                 )
               );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION set_bits_in_bmap_segment_test(pt_bit_numbers_list INT_LIST, pt_bit_map_to_build INT_LIST) RETURN INT_LIST IS
        bit_map bmap_builder.BMAP_SEGMENT;
      BEGIN
        bit_map := bmap_builder.encode_bmap_segment( pt_bit_map_to_build );
        bmap_builder.set_bits_in_bmap_segment( pt_bit_numbers_list, bit_map );
        RETURN bmap_builder.decode_bmap_segment( bit_map );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitminus_test(pt_left INT_LIST, pt_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bmap_segment(
                 bmap_builder.segment_bit_minus(
                   bmap_builder.encode_bmap_segment( pt_left ),
                   bmap_builder.encode_bmap_segment( pt_right )
                 )
               );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_and_insert_bmap( pt_bit_numbers_list INT_LIST ) RETURN INTEGER IS
      BEGIN
        RETURN bmap_persist.insertBitmapLst( bmap_builder.encode_bmap_segment( pt_bit_numbers_list ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_and_update_bmap( key_id INTEGER, pt_bit_numbers_list INT_LIST ) RETURN INTEGER IS
      BEGIN
        RETURN bmap_persist.updateBitmapLst( key_id, bmap_builder.encode_bmap_segment( pt_bit_numbers_list ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_and_set_bmap( pio_bitmap_key IN OUT INTEGER, pt_bit_numbers_list INT_LIST ) RETURN INTEGER IS
      BEGIN
        RETURN bmap_persist.setBitmapLst( pio_bitmap_key, bmap_builder.encode_bmap_segment( pt_bit_numbers_list ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION select_and_decode_bmap( bitmap_key INTEGER  ) RETURN INT_LIST IS
      BEGIN
        RETURN bmap_builder.decode_bmap_segment( bmap_persist.getBitmapLst(  bitmap_key ) );
      END;
    SQL


  end

  after(:all) do
    plsql.execute('DROP FUNCTION encode_decode_test')
    plsql.execute('DROP FUNCTION encode_bitand_test')
    plsql.execute('DROP FUNCTION encode_bitor_test')
    plsql.execute('DROP FUNCTION set_bits_in_bmap_segment_test')
    plsql.execute('DROP FUNCTION encode_bitminus_test')
    plsql.execute('DROP FUNCTION encode_and_insert_bmap')
    plsql.execute('DROP FUNCTION encode_and_update_bmap')
    plsql.execute('DROP FUNCTION select_and_decode_bmap')
  end

  def encode_and_decode_bmap(bit_number_list)
    plsql.encode_decode_test(bit_number_list)
  end

  def segment_bit_and( left, right )
    plsql.encode_bitand_test(left, right)
  end

  def segment_bit_minus( left, right )
    plsql.encode_bitminus_test(left, right)
  end

  def segment_bit_or( left, right )
    plsql.encode_bitor_test(left, right)
  end

  def set_bits_in_bmap_segment(bit_list, bit_map)
    plsql.set_bits_in_bmap_segment_test(bit_list, bit_map)
  end

  def encode_and_insert_bmap(bit_number_list)
    plsql.encode_and_insert_bmap(bit_number_list)
  end

  def encode_and_update_bmap(key_id, bit_number_list)
    plsql.encode_and_update_bmap(key_id, bit_number_list)
  end

  def encode_and_set_bmap(key_id, bit_number_list)
    plsql.encode_and_set_bmap(key_id, bit_number_list)
  end

  def select_and_decode_bmap(bitmap_key)
    plsql.select_and_decode_bmap(bitmap_key)
  end

end

  def encode_bmap_segment(*bit_number_list)
    if bit_number_list.is_a?(Array) && bit_number_list[0].is_a?(Array) then
      plsql.bmap_builder.encode_bmap_segment(bit_number_list[0])
    else
      plsql.bmap_builder.encode_bmap_segment(bit_number_list)
    end
  end

  def decode_bmap_segment(bitmap)
    plsql.bmap_builder.decode_bmap_segment(bitmap)
  end


  def set_bit_in_segment(bit,segment)
    @bits_in_segment*(segment-1)+bit
  end
