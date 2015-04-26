RSpec.shared_context 'shared bitmap builder' do

  before(:all) do
    plsql.dbms_output_stream = STDOUT
    @bits_in_segment = plsql.bmap_segment_builder.C_ELEMENT_CAPACITY
    @max_bit_number = plsql.bmap_segment_builder.C_SEGMENT_CAPACITY
    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION to_bin_int_list(p_bit_numbers_list INT_LIST) RETURN bmap_segment_builder.BIN_INT_LIST IS
        result bmap_segment_builder.BIN_INT_LIST;
      BEGIN
        IF p_bit_numbers_list IS NULL THEN RETURN result; END IF;
        FOR i IN 1 .. p_bit_numbers_list.COUNT LOOP
          result(i) := p_bit_numbers_list(i);
        END LOOP;
        RETURN result;
      END;
    SQL
    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION to_int_list(p_bit_numbers_list bmap_segment_builder.BIN_INT_LIST) RETURN INT_LIST IS
        result INT_LIST := INT_LIST();
      BEGIN
        FOR i IN 1 .. p_bit_numbers_list.COUNT LOOP
          result.EXTEND; result(result.LAST) := p_bit_numbers_list(i);
        END LOOP;
        RETURN result;
      END;
    SQL
    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_decode_test(p_bit_numbers_list INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN to_int_list(bmap_segment_builder.decode_bmap_segment( bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_bit_numbers_list) ) ));
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitand_test(p_left INT_LIST, p_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN to_int_list(
                 bmap_segment_builder.decode_bmap_segment(
                   bmap_segment_builder.segment_bit_and(
                     bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_left) ),
                     bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_right) )
                   )
                 )
               );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitor_test(p_left INT_LIST, p_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN to_int_list(
                 bmap_segment_builder.decode_bmap_segment(
                   bmap_segment_builder.segment_bit_or(
                     bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_left) ),
                     bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_right) )
                   )
                 )
               );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_bmap_segment(p_bit_numbers_list INT_LIST, p_bit_map_to_build INT_LIST) RETURN INT_LIST IS
        bit_map bmap_segment_builder.BMAP_SEGMENT;
      BEGIN
        bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_bit_map_to_build), bit_map );
        bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_bit_numbers_list), bit_map );
        RETURN to_int_list( bmap_segment_builder.decode_bmap_segment( bit_map ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_bitminus_test(p_left INT_LIST, p_right INT_LIST) RETURN INT_LIST IS
      BEGIN
        RETURN to_int_list(
                 bmap_segment_builder.decode_bmap_segment(
                   bmap_segment_builder.segment_bit_minus(
                     bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_left) ),
                     bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_right) )
                   )
                 )
               );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_and_insert_bmap( p_bit_numbers_list INT_LIST ) RETURN INTEGER IS
      BEGIN
        RETURN bmap_persist.insertBitmapLst( bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_bit_numbers_list) ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_and_update_bmap( p_key_id INTEGER, p_bit_numbers_list INT_LIST ) RETURN INTEGER IS
      BEGIN
        RETURN bmap_persist.updateBitmapLst( p_key_id, bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_bit_numbers_list) ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE FUNCTION encode_and_set_bmap( p_bitmap_key IN OUT INTEGER, p_bit_numbers_list INT_LIST ) RETURN INTEGER IS
      BEGIN
        RETURN bmap_persist.setBitmapLst( p_bitmap_key, bmap_segment_builder.encode_bmap_segment( to_bin_int_list(p_bit_numbers_list) ) );
      END;
    SQL

    plsql.execute <<-SQL
      CREATE OR REPLACE PROCEDURE encode_and_insert_segment( p_table_name VARCHAR2, p_bitmap_key INTEGER, p_segment_V_pos INTEGER, p_segment_H_pos INTEGER, p_bit_numbers_list INT_LIST  ) IS
      BEGIN
        bmap_persist.insert_segment(
          p_table_name, p_bitmap_key, p_segment_V_pos, p_segment_H_pos,
          bmap_segment_builder.encode_and_convert( to_bin_int_list(p_bit_numbers_list) )
        );
      END;
    SQL


  end

  after(:all) do
    plsql.execute('DROP FUNCTION to_bin_int_list')
    plsql.execute('DROP FUNCTION to_int_list')
    plsql.execute('DROP FUNCTION encode_decode_test')
    plsql.execute('DROP FUNCTION encode_bitand_test')
    plsql.execute('DROP FUNCTION encode_bitor_test')
    plsql.execute('DROP FUNCTION encode_bmap_segment')
    plsql.execute('DROP FUNCTION encode_bitminus_test')
    plsql.execute('DROP FUNCTION encode_and_insert_bmap')
    plsql.execute('DROP FUNCTION encode_and_update_bmap')
    plsql.execute('DROP FUNCTION encode_and_insert_segment')
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

  def encode_bmap_segment(bit_list, bit_map)
    plsql.encode_bmap_segment(bit_list, bit_map)
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

  def encode_and_insert_segment(table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_number_list)
    plsql.encode_and_insert_segment(table_name, bitmap_key, bitmap_segment_h_pos, bitmap_segment_v_pos, bit_number_list)
  end

end

  def decode_bmap_segment(bitmap)
    plsql.bmap_builder.decode_bmap_segment(bitmap)
  end


  def set_bit_in_segment(bit,segment)
    @bits_in_segment*(segment-1)+bit
  end
