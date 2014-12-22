declare
  a BINARY_INTEGER  := 5;
  b BINARY_INTEGER  := 3;
  expected BINARY_INTEGER  := 4;
  result BINARY_INTEGER :=0;
  full_set BINARY_INTEGER := 2147483647;
  i BINARY_INTEGER  :=0;
begin
--loop
  result := bitand(a, full_set - b); --create a negative mask (full set - bitmap);
  result := a - bitand(a,b); --remove what they have in common
--      exit when result = expected or (offset +i) > 0;
    --end loop;
  dbms_output.put_line('expected: '||expected||' got: '||result||' with mask: '||( full_set - b));
end;
