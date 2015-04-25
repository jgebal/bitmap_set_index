RSpec.shared_context 'shared bitmap storage' do

  def get_segment(table_name, key, h_pos, v_pos)
    plsql.bmap_persist.get_segment(table_name, key, h_pos, v_pos)
  end

  def count_segments(table_name, key)
    sql = <<-SQL
    SELECT COUNT(1) FROM #{table_name}
     WHERE bmap_key = :key
    SQL
    plsql.select_one(sql, key)
  end

  def get_bmap_root_segment(table_name, key)
    get_segment(table_name, key, 1, 3)
  end

  def storage_table_name
    @p_stor_table_name = 'test_bitmap_segments'
  end

  def build_bitmap( table_name, p_bitmap_key, bit_list )
    plsql.build_bitmap( table_name, p_bitmap_key, bit_list )
  end

  before(:all) do
    plsql.bmap_maint.create_index_storage_table( storage_table_name )
    plsql.execute <<-SQL
      CREATE PROCEDURE build_bitmap( p_table_name VARCHAR2, p_bitmap_key INTEGER, p_bit_numbers_list INT_LIST ) IS
        v_crsr SYS_REFCURSOR;
      BEGIN
        OPEN v_crsr FOR 'SELECT '||p_bitmap_key||', COLUMN_VALUE FROM TABLE(:LIST)' USING p_bit_numbers_list;
        bmap_builder.build_bitmaps( v_crsr, p_table_name );
        CLOSE v_crsr;
      END;
    SQL
  end

  after(:all) do
    plsql.execute 'DROP TABLE test_bitmap_segments'
    plsql.execute 'DROP PROCEDURE build_bitmap'
  end


end