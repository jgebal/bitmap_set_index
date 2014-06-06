 CREATE TABLE bitmap_mapping_table(bit_no INTEGER, mapping_node MAPPING_KEY_LIST)
    NESTED TABLE mapping_node STORE AS mapping_node_tab;

ALTER TABLE bitmap_mapping_table ADD CONSTRAINT BIT_NO_UQ UNIQUE (bit_no );

-- drop table bitmap_mapping_table;
