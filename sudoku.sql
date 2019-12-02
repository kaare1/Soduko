create or replace package sudoku as
  

  TYPE sudoku_poss_list IS VARRAY(9) of BOOLEAN;
  TYPE sudoku_board_field IS RECORD (content number, nb_poss number, p_list sudoku_poss_list);
  TYPE sudoku_board_row IS VARRAY(9) of sudoku_board_field;
  TYPE sudoku_board IS VARRAY(9) of sudoku_board_row;
  
  TYPE sudoku_square_list is VARRAY(3) of sudoku_poss_list;
  TYPE sudoku_square_record is RECORD (row sudoku_square_list, col sudoku_square_list);
  TYPE sudoku_square_row is VARRAY(3) of sudoku_square_record;
  TYPE sudoku_square_board is VARRAY(3) of sudoku_square_row;
  
  /*
  poss_list sudoku_poss_list;  
  board_field sudoku_board_field;
  board_row sudoku_board_row;
  board sudoku_board;
  
  square_list sudoku_square_list;
  sudoku_square sudoku_square_record;
  sudoku_square_r sudoku_square_row;
  sudoku_square_b sudoku_square_board;  
  */
  
  procedure createSudokuBoard(return_board IN OUT NOCOPY sudoku_board, return_square_board IN OUT NOCOPY sudoku_square_board);
  procedure createSudokuBoard(board OUT number);
  procedure fillSudokuBoard(board IN OUT NOCOPY sudoku_board, sudoku_square_b IN OUT NOCOPY sudoku_square_board);

  procedure solveSudoku(board IN OUT sudoku_board, sudoku_square_b IN OUT sudoku_square_board);
  function siblingsFound(board IN OUT sudoku_board) return boolean;
  function checkSudokuBoard(board IN sudoku_board) return boolean;
  procedure updateSquareBoard(board IN sudoku_board, sudoku_square_b IN OUT sudoku_square_board);
  
  procedure printBoard(board IN sudoku_board);
  procedure printPossBoard(board IN sudoku_board);
  procedure printSquareBoard(sudoku_square_b IN sudoku_square_board);
  procedure play;
  
end sudoku;
/
show errors
/


create or replace package body sudoku as





procedure removePossRowValues(board IN OUT sudoku_board, i number, j number) is
  content number;
begin
  --Manipulerer soudoku brædtet board.
  --Precondition is that board(i,j) is free and all values 1..9 are listed as possible.
  --Purpose is to remove those number appearing in row i.
  for kol in 1..9 loop
    if board(i)(kol).content is not null  then
	  --The value content is NOT possible anymore.
	  --dbms_output.put_line('ROW: The value '||board(i)(kol).content||' not possible at ('||i||','||j||')');
	  if board(i)(j).p_list(board(i)(kol).content) then
	    board(i)(j).p_list(board(i)(kol).content) := FALSE;
	    board(i)(j).nb_poss := board(i)(j).nb_poss-1;
	  end if; 
	end if;
  end loop;
end removePossRowValues;

procedure removePossColumnValues(board IN OUT sudoku_board, i number, j number) is
begin
  --Manipulerer soudoku brædtet board.
  --Precondition is that board(i,j) is free and all values 1..9 are listed as possible.
  --Purpose is to remove those number appearing in column j.
  for r in 1..9 loop
    if board(r)(j).content is not null then
	  --The value content is NOT possible anymore.
	  --dbms_output.put_line('COLUMN: The value '||board(r)(j).content||' not possible at ('||i||','||j||')');
	  if board(i)(j).p_list(board(r)(j).content) then
	    board(i)(j).p_list(board(r)(j).content) := FALSE;
	    board(i)(j).nb_poss := board(i)(j).nb_poss-1;
	  end if;	  
	end if;
  end loop;
end removePossColumnValues;

procedure removePossSquareValues(board IN OUT sudoku_board, i number, j number) is
  i1 number;
  j1 number;
begin
  --Manipulerer soudoku brædtet board.
  --Precondition is that board(i,j) is free and all values 1..9 are listed as possible.
  --Purpose is to remove those number appearing in the 3x3 square that field (i,j) belongs to.
  case i
    when 1 then i1:=1;
	when 2 then i1:=1;
	when 3 then i1:=1;
	when 4 then i1:=4;
	when 5 then i1:=4;
	when 6 then i1:=4;
	when 7 then i1:=7;
	when 8 then i1:=7;
	when 9 then i1:=7;
  end case;
  case j
    when 1 then j1:=1;
	when 2 then j1:=1;
	when 3 then j1:=1;
	when 4 then j1:=4;
	when 5 then j1:=4;
	when 6 then j1:=4;
	when 7 then j1:=7;
	when 8 then j1:=7;
	when 9 then j1:=7;
  end case;
  
  for m in i1..i1+2 loop
    for n in j1..j1+2 loop
      if board(m)(n).content is not null then
	    --The value content is NOT possible anymore.
	    --dbms_output.put_line('SQUARE: The value '||board(m)(n).content||' not possible at ('||i||','||j||')');
	    if board(i)(j).p_list(board(m)(n).content) then
		  board(i)(j).p_list(board(m)(n).content) := FALSE;
	      board(i)(j).nb_poss := board(i)(j).nb_poss-1;
		end if;		
	  end if;
	end loop;
  end loop;
end removePossSquareValues;

/*
procedure registerSquareValues(i number, j number) 
  --Manipulerer soudoku kvadrarbrædtet sudoku_square_b.
is
  x number := 0;
  y number := 0;
  x2 number := 0;
  y2 number := 0;
begin
  x := ((i-1)*3)+1;
  y := ((j-1)*3)+1;
  
  for x1 in x..x+2 loop
    for y1 in y..y+2 loop
	  for c in 1..9 loop
	    if board(x1)(y1).p_list(c) then
		  x2 := mod(x1,3);
		  if x2=0 then x2 := 3; end if;
		  y2 := mod(y1,3);
		  if y2=0 then y2 := 3; end if;
		  sudoku_square_b(i)(j).row(x2)(c):= true;
		  sudoku_square_b(i)(j).col(y2)(c):= true;		  
		end if;
	  end loop;
	end loop;
  end loop;
end registerSquareValues;
*/
procedure createSudokuBoard(board OUT number) 
is
begin
  board :=7;
end createSudokuBoard;

procedure createSudokuBoard(return_board IN OUT NOCOPY sudoku_board, return_square_board IN OUT NOCOPY  sudoku_square_board) 
is
  poss_list sudoku_poss_list;  
  board_field sudoku_board_field;
  board_row sudoku_board_row;
  board sudoku_board;
  
  square_list sudoku_square_list;
  sudoku_square sudoku_square_record;
  sudoku_square_r sudoku_square_row;
  sudoku_square_b sudoku_square_board;
begin

  poss_list := sudoku_poss_list(true,true,true,true,true,true,true,true,true);
  board_field.content := null;
  board_field.nb_poss := 9;
  board_field.p_list := poss_list;
  
  board_row := sudoku_board_row(board_field);
  board_row.extend(8,1);

  board := sudoku_board(board_row);
  board.extend(8,1); 
  return_board:=board;
  
  poss_list := sudoku_poss_list(false,false,false,false,false,false,false,false,false);
  square_list := sudoku_square_list(poss_list);
  square_list.extend(2,1);
  sudoku_square.row := square_list;
  sudoku_square.col := square_list;
  sudoku_square_r := sudoku_square_row(sudoku_square);
  sudoku_square_r.extend(2,1);
  sudoku_square_b := sudoku_square_board(sudoku_square_r);
  sudoku_square_b.extend(2,1);
  return_square_board := sudoku_square_b;
  dbms_output.put_line('create finished');    
end createSudokuBoard;


procedure fillSudokuBoard(board IN OUT NOCOPY sudoku_board, sudoku_square_b IN OUT NOCOPY sudoku_square_board)
 is
  --Udfylder board. Kalder updateSquareBoard, hvilket den ikke behøver.
  --Proceduren skal udvides med to IN/OUT parametre BOARD og SQUARE_BOARD.
  --Disse to parametre sendes også med i kaldet til updateSquareBoard.
  --Overvej, at lade være med at kalde updateSquareBoard. Hvad kan konsekvensen være?  
  i number;
  
  cursor cGetSudokuBoard is
    select c1,c2,c3,c4,c5,c6,c7,c8,c9
	from   sudoku_board
	order by r;

begin
  --Read content from table into sudoku board.
  i := 1;
  for ro in cGetSudokuBoard loop
    if ro.c1 is not null then board(i)(1).content := ro.c1; end if;
    if ro.c2 is not null then board(i)(2).content := ro.c2; end if;
    if ro.c3 is not null then board(i)(3).content := ro.c3; end if;
    if ro.c4 is not null then board(i)(4).content := ro.c4; end if;
    if ro.c5 is not null then board(i)(5).content := ro.c5; end if;
    if ro.c6 is not null then board(i)(6).content := ro.c6; end if;
    if ro.c7 is not null then board(i)(7).content := ro.c7; end if;
    if ro.c8 is not null then board(i)(8).content := ro.c8; end if;
    if ro.c9 is not null then board(i)(9).content := ro.c9; end if;
    i:=i+1;	
  end loop;

  --For each empty field, calculate the list of possible values.
  for i in 1..9 loop
    for j in 1..9 loop
	  if board(i)(j).content is null then
	    removePossRowValues(board,i,j);
	    removePossColumnValues(board,i,j);
        removePossSquareValues(board,i,j);
	  else
		board(i)(j).nb_poss:=0;
		for c in 1..9 loop
		  board(i)(j).p_list(c ) := false;
		end loop;
	  end if;
    end loop;
  end loop;
  
  updateSquareBoard(board, sudoku_square_b);
  
end fillSudokuBoard;

function checkSudokuBoard(board IN sudoku_board) return boolean
is
  --Arbejder kun på datastrukturen board.
  --Set all occurcences of numbers 1..9 false.
  one boolean := FALSE;
  two boolean := FALSE;
  three boolean := FALSE;
  four boolean := FALSE;
  five boolean := FALSE;
  six boolean := FALSE;
  seven boolean := FALSE;
  eight boolean := FALSE;
  nine boolean := FALSE;
begin
  --Loop through all nine rows and check that each number 1..9 appears.
  for r in 1..9 loop
    for c in 1..9 loop
	  case board(r)(c ).content
	    when 1 then one := TRUE;
	    when 2 then two := TRUE;
	    when 3 then three := TRUE;
	    when 4 then four := TRUE;
	    when 5 then five := TRUE;
	    when 6 then six := TRUE;
	    when 7 then seven := TRUE;
	    when 8 then eight := TRUE;
	    when 9 then nine := TRUE;
		else        begin 	  
		              dbms_output.put_line('Field ('||r||','||c||') is empty');
					  return false;--A field is empty, return false.
					end;
	  end case;
	end loop;

	if not (one AND two AND three AND four AND five AND six AND seven AND eight AND nine) then
	  --In row r there is one or more numbers missing.
	  dbms_output.put_line('Row '||r||' is bad.');
	  return false;
	end if;

    --Set all occurcences of numbers 1..9 false.	
    one  := FALSE;
    two  := FALSE;
    three  := FALSE;
    four  := FALSE;
    five  := FALSE;
    six  := FALSE;
    seven  := FALSE;
    eight  := FALSE;
    nine  := FALSE;
  end loop;
  
  --Set all occurcences of numbers 1..9 false.
  one  := FALSE;
  two  := FALSE;
  three  := FALSE;
  four  := FALSE;
  five  := FALSE;
  six  := FALSE;
  seven  := FALSE;
  eight  := FALSE;
  nine  := FALSE;

  --Loop through all nine columns and check that each number 1..9 appears.
  for c in 1..9 loop
    for r in 1..9 loop
	  case board(r)(c ).content
	    when 1 then one := TRUE;
	    when 2 then two := TRUE;
	    when 3 then three := TRUE;
	    when 4 then four := TRUE;
	    when 5 then five := TRUE;
	    when 6 then six := TRUE;
	    when 7 then seven := TRUE;
	    when 8 then eight := TRUE;
	    when 9 then nine := TRUE;
		else        begin 	  
		              dbms_output.put_line('Field ('||r||','||c||') is empty');
					  return false;--A field is empty, return false.
					end;
	  end case;
	end loop;

	if not (one AND two AND three AND four AND five AND six AND seven AND eight AND nine) then
	  --In column c there is one or more numbers missing.
	  dbms_output.put_line('Column '||c||' is bad.');
	  return false;
	end if;

    --Set all occurcences of numbers 1..9 false.	
    one  := FALSE;
    two  := FALSE;
    three  := FALSE;
    four  := FALSE;
    five  := FALSE;
    six  := FALSE;
    seven  := FALSE;
    eight  := FALSE;
    nine  := FALSE;
  end loop;
  
  --Set all occurcences of numbers 1..9 false.	
  one  := FALSE;
    two  := FALSE;
    three  := FALSE;
    four  := FALSE;
    five  := FALSE;
    six  := FALSE;
    seven  := FALSE;
    eight  := FALSE;
    nine  := FALSE;
	
  --Go through the nine 3x3 squares and check that each number 1..9 appears.
  for i in 1..9 loop
    for j in 1..9 loop
	  if mod(i,3)=1 and mod(j,3)=1 then
	    for m in i..i+2 loop
		  for  n in j..j+2 loop
	        case board(m)(n).content
	          when 1 then one := TRUE;
	          when 2 then two := TRUE;
	          when 3 then three := TRUE;
	          when 4 then four := TRUE;
	          when 5 then five := TRUE;
	          when 6 then six := TRUE;
	          when 7 then seven := TRUE;
	          when 8 then eight := TRUE;
	          when 9 then nine := TRUE;
		      else        begin 	  
		              dbms_output.put_line('Field ('||m||','||n||') is empty');
					  return false;--A field is empty, return false.
					end;
	        end case;
		  end loop;
	    end loop;
		if not (one AND two AND three AND four AND five AND six AND seven AND eight AND nine) then
	      dbms_output.put_line('The 3x3 square starting in ('||i||','||j||') is bad.');	      
	      return false;
	    end if;

	  end if;
	end loop;
  end loop;
  
  return TRUE;

end checkSudokuBoard;

function uniquePossibility(board IN sudoku_board, i number, j number, c number) return boolean
  --Arbejder kun på datastrukturen board.
is
  uniquePossibility boolean := false;
begin
 if board(i)(j).p_list(c ) and board(i)(j).content is null then
    uniquePossibility := true;
    for k in 1..c-1 loop
	  if board(i)(j).p_list(k) then
	    uniquePossibility := false;
	  end if;
	end loop;
	for k in c+1..9 loop
	  if board(i)(j).p_list(k) then
	    uniquePossibility := false;
	  end if;
	end loop;
  end if;
  if uniquePossibility then
    dbms_output.put_line('Unique possibility: '||i||' '||j||' '||c);
    return true;
  else
    return false;
  end if;
end uniquePossibility;

function rowMarkable(board IN sudoku_board, i number, j number, c number) return boolean
  --Arbejder kun på datastrukturen board.
is
  possibilities number := 0;
begin
    for k in 1..9 loop
      if board(i)(k).p_list(c ) then		
        possibilities := possibilities+1;
	  end if;	    
    end loop;

    if board(i)(j).p_list(c ) and possibilities=1 and board(i)(j).content is null then
      dbms_output.put_line('Row markable: '||i||' '||j||' '||c);	
	  return true;
	else
	  return false;
	end if; 
	
end rowMarkable;

function columnMarkable(board IN sudoku_board, i number, j number, c number) return boolean
  --Arbejder kun på datastrukturen board.
is
  possibilities number := 0;
begin
    for k in 1..9 loop
      if board(k)(j).p_list(c ) then
        possibilities := possibilities+1;
	  end if;
    end loop;

    if board(i)(j).p_list(c ) and possibilities=1  and board(i)(j).content is null then
      dbms_output.put_line('column markable: '||i||' '||j||' '||c);
	  return true;
	else
	  return false;
	end if; 
end columnMarkable;

function squareMarkable(board IN sudoku_board, i number, j number, c number) return boolean
  --Arbejder kun på datastrukturen board.
is
  i1 number;
  j1 number;
  possibilities number := 0;
begin
  case i
    when 1 then i1:=1;
	when 2 then i1:=1;
	when 3 then i1:=1;
	when 4 then i1:=4;
	when 5 then i1:=4;
	when 6 then i1:=4;
	when 7 then i1:=7;
	when 8 then i1:=7;
	when 9 then i1:=7;
  end case;
  case j
    when 1 then j1:=1;
	when 2 then j1:=1;
	when 3 then j1:=1;
	when 4 then j1:=4;
	when 5 then j1:=4;
	when 6 then j1:=4;
	when 7 then j1:=7;
	when 8 then j1:=7;
	when 9 then j1:=7;
  end case;
  
  for m in i1..i1+2 loop
    for n in j1..j1+2 loop
      if board(m)(n).p_list(c ) then
        possibilities := possibilities+1;
	  end if;	  
	end loop;
  end loop;
  if board(i)(j).p_list(c ) and possibilities=1  and board(i)(j).content is null then
    dbms_output.put_line('Square markable: '||i||' '||j||' '||c);
	return true;
  else
    return false;
  end if; 
end squareMarkable;

  
function markable(board IN sudoku_board, i number, j number, c number) return boolean
is
  --Arbejder kun på datastrukturen board.
begin
--  dbms_output.put_line('Checking if ('||i||','||j||') can be marked '||c);
  if uniquePossibility(board,i,j,c) then
    return true;
  end if;
  if rowMarkable(board,i,j,c) then
    return true;
  end if;
  if columnMarkable(board,i,j,c) then
    return true;
  end if;
  if squareMarkable(board,i,j,c) then
    return true;
  end if;
  return false;
end markable;

procedure removeRowPossibilities(board IN OUT sudoku_board, sudoku_square_b IN OUT sudoku_square_board, i number, c number)
  --Arbejder på både datastrukturen board og sudoku_board_b. Kan deles op.
is
  z number;
  r number;
begin
  --The digit c has been placed at row i, and now we must rule out the possibility of 
  --placing c anywhere else in row i. For each column j, consult board(i)(j).
  for j in 1..9 loop
    if board(i)(j).p_list(c ) then
      --First, rule out c from the board of possibilities.
	  board(i)(j).p_list(c ):= false;
	  board(i)(j).nb_poss := board(i)(j).nb_poss-1;
	end if;
  end loop;
 --transform board row i to 1,2 or 3 in the 3x3 board of squares.
  r := floor((i-1)/3)+1;
  --Find the row number inside the square. Ex 3=3, 4=1, 5=2, 6=3, etc.
  z:= mod(i,3);
  if z=0 then z := 3; end if;
 --Second, remove c as possible at in the three squares, at the level of row i. i.e. level r.
  for col in 1..3 loop
    --Digit c is no longer possible at square row z in squares at level r.
    sudoku_square_b(r)(col).row(z)(c) := false;   	    
  end loop;
  dbms_output.put_line('removeRowPossibilities ok');
end removeRowPossibilities;

procedure removeColumnPossibilities(board IN OUT sudoku_board, sudoku_square_b IN OUT sudoku_square_board, j number, c number)
  --Arbejder på både datastrukturen board og sudoku_board_b. Kan dele op.
is
  z number;
  colonne number;
begin
  for i in 1..9 loop
    if board(i)(j).p_list(c) then
      board(i)(j).p_list(c):= false;
	  board(i)(j).nb_poss:=board(i)(j).nb_poss-1;
	end if;
  end loop;
 --transform board column j to 1,2 or 3 in the 3x3 board of squares.
  colonne := floor((j-1)/3)+1;
  --Find the column number inside the square. Ex 3=3, 4=1, 5=2, 6=3, etc.
  z:= mod(j,3);
  if z=0 then z := 3; end if;
 --Second, remove c as possible at in the three squares, at the level of row i. i.e. level r.
  for raekke in 1..3 loop
    --Digit c is no longer possible at square col z in squares at level colonne.
    sudoku_square_b(raekke)(colonne).col(z)(c) := false;   	    
  end loop;
  dbms_output.put_line('removeColumnPossibilities ok');
end removeColumnPossibilities;


procedure removeSquarePossibilities(board IN OUT sudoku_board, sudoku_square_b IN OUT sudoku_square_board, i number, j number, c number)
  --Arbejder på både datastrukturen board og sudoku_board_b. Kan deles op.
is 
  i1 number;
  j1 number;  
  x number;
  y number;
  rk number;
  cl number;
begin
  i1 := 3*(floor((i-1)/3))+1;
  j1 := 3*(floor((j-1)/3))+1;

  --Precondition: digit c has been placed at the board at position (i,j).
  --Consequently, it is not possible anywhere else in this 3x3 square.  
  for m in i1..i1+2 loop
    for n in j1..j1+2 loop
	  if board(m)(n).p_list(c) then
        board(m)(n).p_list(c):= false;
		board(m)(n).nb_poss:=board(m)(n).nb_poss-1;
      end if;
	end loop;
  end loop;
  x := floor((i-1)/3)+1;
  y := floor((j-1)/3)+1;
  --Next, mark in the board of squares that c is no longer possible at any row or column in 
  --this 3x3 square.
  for r in 1..3 loop
    sudoku_square_b(x)(y).row(r)(c) := false;
    sudoku_square_b(x)(y).col(r)(c) := false;
  end loop;
  --Finally, in this particular 3x3 square no digits are possible in the row corresponding to row i,
  --and there are no digits possible in the column corresponding to column j.
  --WHY????????? 
  /*
  rk := mod(i,3); if rk=0 then rk:=3; end if;
  cl := mod(j,3); if cl=0 then cl:=3; end if;
  for p in 1..9 loop
    sudoku_square_b(x)(y).row(rk)(p) := false;
	sudoku_square_b(x)(y).col(cl)(p) := false;
  end loop;
  */
  dbms_output.put_line('removeSquarePossibilities ok');
end removeSquarePossibilities;


function siblingsInColumn(board IN OUT sudoku_board, i number) return boolean
  --Arbejder på datastrukturen board.
is
  siblingsFound boolean;
  firstSiblingFound boolean := false;
  firstSibling number;
  secondSibling number;
  changes boolean := false;
begin
  siblingsFound := false;
  --Find all pairs of cells in column i.
  for m in 1..9 loop
    for j in m+1..9 loop
	  --If the number of possible markings at position m and j are two then we possibly have a pair of identical siblings.
	  if board(m)(i).nb_poss=2 and board(j)(i).nb_poss=2 then
	    siblingsFound := true;
	    for p in 1..9 loop
		  if not(board(m)(i).p_list(p)=board(j)(i).p_list(p)) then
		    --If they do not match on their possibilities we do not have a match.
		    siblingsFound := false;		  
		  end if;
		end loop;
		if siblingsFound then
		  for p in 1..9 loop
		    if board(m)(i).p_list(p) then
			  if firstSiblingFound then
			    secondSibling := p;
			  else
			    firstSibling := p;
				firstSiblingFound := true;
			  end if;
			end if;
		  end loop;
		  firstSiblingFound := false;
		  --We know that firstSibling and secondSibling must be at row i, position m and j. 
		  --Consequently they are not possible at any other positions in row i.
		  dbms_output.put_line('Siblings, column '||i||' positions '||m||' and '||j||' values '||firstSibling||','||secondSibling);
		  for v in 1..9 loop
		    if board(v)(i).p_list(firstSibling) and v<>m and v<> j then
			  dbms_output.put_line('Column '||i||' removing possibility '||firstSibling||' at position '||v);
		      board(v)(i).p_list(firstSibling) := false;
			  board(v)(i).nb_poss := board(v)(i).nb_poss-1;
			  changes := true;
			end if;
		    if board(v)(i).p_list(secondSibling) and v<>m and v<>j then
			  dbms_output.put_line('Column '||i||' removing possibility '||secondSibling||' at position '||v);
		      board(v)(i).p_list(secondSibling) := false;
			  board(v)(i).nb_poss := board(i)(v).nb_poss-1;
			  changes := true;
			end if;			
		  end loop;
		end if;
	  end if;
	end loop;
  end loop;
  return changes;
end siblingsInColumn;

function siblingsInRow(board IN OUT sudoku_board, i number) return boolean
  --Arbejder på datastrukturen board.
is
  siblingsFound boolean;
  firstSiblingFound boolean := false;
  firstSibling number;
  secondSibling number;
  changes boolean := false;
begin
  siblingsFound := false;
  --Find all pairs of cells in row i.
  for m in 1..9 loop
    for j in m+1..9 loop
	  --If the number of possible markings at position m and j are two then we possibly have a pair of identical siblings.
	  if board(i)(m).nb_poss=2 and board(i)(j).nb_poss=2 then
	    siblingsFound := true;
	    for p in 1..9 loop
		  if not(board(i)(m).p_list(p)=board(i)(j).p_list(p)) then
		    --If they do not match on their possibilities we do not have a match.
		    siblingsFound := false;		  
		  end if;
		end loop;
		if siblingsFound then
		  for p in 1..9 loop
		    if board(i)(m).p_list(p) then
			  if firstSiblingFound then
			    secondSibling := p;
			  else
			    firstSibling := p;
				firstSiblingFound := true;
			  end if;
			end if;
		  end loop;
		  firstSiblingFound := false;
		  --We know that firstSibling and secondSibling must be at row i, position m and j. 
		  --Consequently they are not possible at any other positions in row i.
		  dbms_output.put_line('Siblings, row '||i||' positions '||m||' and '||j||' values '||firstSibling||','||secondSibling);
		  for v in 1..9 loop
		    if board(i)(v).p_list(firstSibling) and v<>m and v<> j then
			  dbms_output.put_line('Row '||i||' removing possibility '||firstSibling||' at position '||v);
		      board(i)(v).p_list(firstSibling) := false;
			  board(i)(v).nb_poss := board(i)(v).nb_poss-1;
			  changes := true;
			end if;
		    if board(i)(v).p_list(secondSibling) and v<>m and v<>j then
			  dbms_output.put_line('Row '||i||' removing possibility '||secondSibling||' at position '||v);
		      board(i)(v).p_list(secondSibling) := false;
			  board(i)(v).nb_poss := board(i)(v).nb_poss-1;
			  changes := true;
			end if;			
		  end loop;
		end if;
	  end if;
	end loop;
  end loop;
  return changes;
end siblingsInRow;

function siblingsInSquare(board IN OUT sudoku_board, i number) return boolean
  --Arbejder på datastrukturen board.
is
  i1 number;
  j1 number;
  siblingsFound boolean;
  firstSiblingFound boolean := false;
  firstSibling number;
  secondSibling number;
  changes boolean := false;
begin
  case i
    when 1 then i1:=1;j1:=1;
	when 2 then i1:=1;j1:=4;
	when 3 then i1:=1;j1:=7;
	when 4 then i1:=4;j1:=1;
	when 5 then i1:=4;j1:=4;
	when 6 then i1:=4;j1:=7;
	when 7 then i1:=7;j1:=1;
	when 8 then i1:=7;j1:=4;
	when 9 then i1:=7;j1:=7;
  end case;
  siblingsFound := false;
  --Find all pairs of cells square i.
  for m in i1..i1+2 loop
    for j in j1..j1+2 loop
	  for x in m+1..i1+2 loop
	    for y in j+1..j1+2 loop
	      --If the number of possible markings at position m and j are two then we possibly have a pair of identical siblings.
	      if board(m)(j).nb_poss=2 and board(x)(y).nb_poss=2 then
	        siblingsFound := true;
	        for p in 1..9 loop
		      if not(board(m)(j).p_list(p)=board(x)(y).p_list(p)) then
		        --If they do not match on their possibilities we do not have a match.
		        siblingsFound := false;		  
		      end if;
		    end loop;
		    if siblingsFound then
		      for p in 1..9 loop
		        if board(m)(j).p_list(p) then
			      if firstSiblingFound then
			        secondSibling := p;
			      else
			        firstSibling := p;
				    firstSiblingFound := true;
			      end if;
			    end if;
		      end loop;
		      firstSiblingFound := false;
		      --We know that firstSibling and secondSibling must be at rsquare i, position (m,j) and (x,y). 
		      --Consequently they are not possible at any other positions in square i.
		      dbms_output.put_line('Siblings, square '||i||' positions ('||m||','||j||') and ('||x||','||y||') values '||firstSibling||','||secondSibling);
		      for v in i1..i1+2 loop
		        for w in j1..j1+2 loop
		          if board(v)(w).p_list(firstSibling) and (not (v=m and w=j)) and (not (v=x and w=y)) then
			        dbms_output.put_line('square '||i||' removing possibility '||firstSibling||' at position ('||v||','||w||')');
		            board(i)(v).p_list(firstSibling) := false;
			        board(i)(v).nb_poss := board(i)(v).nb_poss-1;
			        changes := true;
			      end if;
		          if board(v)(w).p_list(secondSibling) and (not (v=m and w=j)) and (not (v=x and w=y)) then
			        dbms_output.put_line('square '||i||' removing possibility '||secondSibling||' at position ('||v||','||w||')');
		            board(i)(v).p_list(secondSibling) := false;
			        board(i)(v).nb_poss := board(i)(v).nb_poss-1;
			        changes := true;
			      end if;			
		        end loop;
		      end loop;
		    end if;
	      end if;
		end loop;
      end loop;
	end loop;
  end loop;
  return changes;
end siblingsInSquare;

function hiddenPairsInRow(board IN OUT sudoku_board, i in integer) return boolean
is
  changes boolean := false;
  match boolean := false;
begin
  --The row is fixed to be i 
  for j1 in 1..9 loop --Fix first column j1 
    for j2 in j1+1..9 loop --Fix second column j2 
	  for c1 in 1..9 loop --Fix first digit c1 
	    for c2 in c1+1..9 loop --Fix second digit c2.  
		  --if c1 and c2 are possible at cells (i,j1) and (i,j2) and not possible at others cells at row i, then no other 
		  --digits are possible at cells (i,j1) and (i,j2).
          match:=false;
		  if board(i)(j1).p_list(c1) and board(i)(j2).p_list(c1) and board(i)(j1).p_list(c2) and board(i)(j2).p_list(c2) then
            match:=true;
			--Check that nor c1 or c2 are possible at any other cells in row i.
			for j in 1..9 loop
			  if j<>j1 and j<>j2 then
			    if board(i)(j).p_list(c1)=true or board(i)(j).p_list(c2)=true then
				  match:=false;
				end if; 
			  end if;
			end loop;
			if match then
			  --remove any digit c other than c1 and c2 as possible at cells (i,j1) and (i,j2)-
			  dbms_output.put_line('Hidden Pair found');
		      for c in 1..9 loop
				if c<>c1 and c<>c2 then
				  if board(i)(j1).p_list(c) then
				    dbms_output.put_line('Removing possibility.');
			        board(i)(j1).p_list(c):=false;
					board(i)(j1).nb_poss:=board(i)(j1).nb_poss-1;
					changes:=true;
			      end if;
				  if board(i)(j2).p_list(c) then
				    dbms_output.put_line('Removing possibility.');
			        board(i)(j2).p_list(c):=false;
					board(i)(j2).nb_poss:=board(i)(j1).nb_poss-1;
					changes:=true;					
			      end if;				  
			    end if;
			  end loop;
			end if;
          end if;		   
		end loop;
	  end loop;
	end loop;
  end loop;
  return changes;
end hiddenPairsInRow;

function hiddenPairsInColumn(board IN OUT sudoku_board, j in integer) return boolean
is
  changes boolean := false;
  match boolean := false;
begin
  --The column is fixed to be j 
  for i1 in 1..9 loop --Fix first row i1 
    for i2 in i1+1..9 loop --Fix second row i2 
	  for c1 in 1..9 loop --Fix first digit c1 
	    for c2 in c1+1..9 loop --Fix second digit c2.  
		  --if c1 and c2 are possible at cells (i1,j) and (i2,j) and not possible at others cells at column j, then no other 
		  --digits are possible at cells (i1,j) and (i2,j).
          match:=false;
		  if board(i1)(j).p_list(c1) and board(i2)(j).p_list(c1) and board(i1)(j).p_list(c2) and board(i2)(j).p_list(c2) then
            match:=true;
			--Check that nor c1 or c2 are possible at any other cells in column j.
			for i in 1..9 loop
			  if i<>i1 and i<>i2 then
			    if board(i)(j).p_list(c1)=true or board(i)(j).p_list(c2)=true then
				  match:=false;
				end if; 
			  end if;
			end loop;
			if match then
			  --remove any digit c other than c1 and c2 as possible at cells (i,j1) and (i,j2)-
			  dbms_output.put_line('Hidden Pair found');
		      for c in 1..9 loop
				if c<>c1 and c<>c2 then
				  if board(i1)(j).p_list(c) then
				    dbms_output.put_line('Removing possibility.');
			        board(i1)(j).p_list(c):=false;
					board(i1)(j).nb_poss:=board(i1)(j).nb_poss-1;
					changes:=true;
			      end if;
				  if board(i2)(j).p_list(c) then
				    dbms_output.put_line('Removing possibility.');
			        board(i2)(j).p_list(c):=false;
					board(i2)(j).nb_poss:=board(i2)(j).nb_poss-1;
					changes:=true;					
			      end if;				  
			    end if;
			  end loop;
			end if;
          end if;		   
		end loop;
	  end loop;
	end loop;
  end loop;
  return changes;
end hiddenPairsInColumn;

function hiddenPairsInSquare(board IN OUT sudoku_board, s in integer) return boolean
is
  i1 number;
  j1 number;
  match boolean := false;
  changes boolean := false;
begin
  case s
    when 1 then i1:=1;j1:=1;
	when 2 then i1:=1;j1:=4;
	when 3 then i1:=1;j1:=7;
	when 4 then i1:=4;j1:=1;
	when 5 then i1:=4;j1:=4;
	when 6 then i1:=4;j1:=7;
	when 7 then i1:=7;j1:=1;
	when 8 then i1:=7;j1:=4;
	when 9 then i1:=7;j1:=7;
  end case;
  --Find all pairs of cells square i.
  for m in i1..i1+2 loop
    for j in j1..j1+2 loop
	  for x in m+1..i1+2 loop
	    for y in j+1..j1+2 loop
          --Now we have a pair of cells (m,j) and (x,y).
		  for c1 in 1..9 loop --Fix first digit c1 
		    for c2 in c1+1..9 loop --Fix second digit c2.
			  match:=false;
			  if board(m)(j).p_list(c1) and board(m)(j).p_list(c2) and board(x)(y).p_list(c1) and board(x)(y).p_list(c2) then
			    match:=true;
			    --Check that nor c1 or c2 are possible at any other cells in square s.
			    for rk in i1..i1+2 loop
			      for cl in j1..j1+2 loop
			        if not (rk=m and cl=j) or (rk=x and cl=y) then
			          if board(rk)(cl).p_list(c1)=true or board(rk)(cl).p_list(c2)=true then
				        match:=false;
				      end  if; 
			        end if;
			      end loop;
			    end loop;
			    if match then
			      --remove any digit c other than c1 and c2 as possible at cells (m,j) and (x,y)-
			      dbms_output.put_line('Hidden Pair found in square');
		          for c in 1..9 loop
				    if c<>c1 and c<>c2 then
				      if board(m)(j).p_list(c) then
				        dbms_output.put_line('Removing possibility from square');
			            board(m)(j).p_list(c):=false;
					    board(m)(j).nb_poss:=board(m)(j).nb_poss-1;
					    changes:=true;
			          end if;
				      if board(x)(y).p_list(c) then
				        dbms_output.put_line('Removing possibility from square');
			            board(x)(y).p_list(c):=false;
					    board(x)(y).nb_poss:=board(x)(y).nb_poss-1;
					    changes:=true;					
			          end if;				  
			        end if;
			      end loop;
			    end if;	
			  end if;		  
			end loop;
		  end loop;   
		end loop;
      end loop;
	end loop;
  end loop;
  return changes;
end hiddenPairsInSquare;
  

function hiddenPairs(board IN OUT sudoku_board) return boolean 
is
  changes boolean := false;
begin
  dbms_output.put_line('Hidden Pairs begin');
  for i in 1..9 loop
    if hiddenPairsInRow(board, i) then
	  changes := true;
	end if;
  end loop;
  for j in 1..9 loop
    if hiddenPairsInColumn(board, j) then
	  changes := true;
	end if;
  end loop;  
  for s in 1..9 loop
    if hiddenPairsInSquare(board, s) then
	  return true;
	end if;
  end loop;
  dbms_output.put_line('Hidden Pairs end');  
  return changes;
end hiddenPairs;

function siblingsFound(board IN OUT sudoku_board) return boolean 
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
begin
  dbms_output.put_line('Siblings found begin');
  for i in 1..9 loop
    if SiblingsInRow(board, i) then
	  changes := true;
	end if;
  end loop;
  for j in 1..9 loop
    if SiblingsInColumn(board, j) then
	  changes := true;
	end if;
  end loop;  
  for i in 1..9 loop
    if siblingsInSquare(board, i) then
	  return true;
	end if;
  end loop;
  dbms_output.put_line('Siblings found end');  
  return changes;
end siblingsFound;

function possRow(board sudoku_board, c in integer, i1 in integer, i2 in integer, j1 in integer, j2 in integer) return boolean 
is
begin
  for j in 1..9 loop
    if board(i1)(j).p_list(c) and j<>j1 and j<>j2 then
	  return true;
	end if;
    if board(i2)(j).p_list(c) and j<>j1 and j<>j2 then
	  return true;
	end if;	
  end loop;
  return false;
end possRow;

function possCol(board sudoku_board, c in integer, i1 in integer, i2 in integer, j1 in integer, j2 in integer) return boolean 
is
begin
  for i in 1..9 loop
    if board(i)(j1).p_list(c) and i<>i1 and i<>i2 then
	  return true;
	end if;
    if board(i)(j2).p_list(c) and i<>i1 and i<>i2 then
	  return true;
	end if;	
  end loop;
  return false;
end possCol;

function XWing(board IN OUT sudoku_board) return boolean
is
  changes boolean := false;
begin
  dbms_output.put_line('XWing begin');
  for i1 in 1..9 loop
    for i2 in i1+1..9 loop
	  for j1 in 1..9 loop
	    for j2 in j1+1..9 loop
		  for c in 1..9 loop
		    if board(i1)(j1).p_list(c) and board(i1)(j2).p_list(c) and board(i2)(j1).p_list(c) and board(i2)(j2).p_list(c) and (not possRow(board,c,i1,i2,j1,j2)) then
              for i in 1..9 loop
			    if i<>i1 and i<>i2 then
                  if board(i)(j1).p_list(c) then
                    board(i)(j1).p_list(c):= false;
	                board(i)(j1).nb_poss:=board(i)(j1).nb_poss-1;
				    dbms_output.put_line('X-Wing Removing possibility.');					
	              end if;
                  if board(i)(j2).p_list(c) then
                    board(i)(j2).p_list(c):= false;
	                board(i)(j2).nb_poss:=board(i)(j2).nb_poss-1;
				    dbms_output.put_line('X-Wing Removing possibility.');					
	              end if;				  
				end if;
              end loop;
			end if; 

		    if board(i1)(j1).p_list(c) and board(i1)(j2).p_list(c) and board(i2)(j1).p_list(c) and board(i2)(j2).p_list(c) and (not possCol(board,c,i1,i2,j1,j2)) then
              for j in 1..9 loop
			    if j<>j1 and j<>j2 then
                  if board(i1)(j).p_list(c) then
                    board(i1)(j).p_list(c):= false;
	                board(i1)(j).nb_poss:=board(i1)(j).nb_poss-1;
				    dbms_output.put_line('Y-Wing Removing possibility.');					
	              end if;
                  if board(i1)(j).p_list(c) then
                    board(i1)(j).p_list(c):= false;
	                board(i1)(j).nb_poss:=board(i1)(j).nb_poss-1;
				    dbms_output.put_line('Y-Wing Removing possibility.');					
	              end if;				  
				end if;
               end loop;
			end if; 

		  end loop;
		end loop;
	  end loop;
	end loop;
  end loop;
  dbms_output.put_line('XWing end');  
  return changes;
end XWing;


function horizontalObstructingElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board, i in number, j in number) return boolean
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
  o1 number :=0;
  o2 number :=0;
  rk number :=0;
  k number := 0;
begin
  dbms_output.put_line('horizontalObstructingElements begin square=('||i||','||j||')');
  for r in 1..3 loop
    case r
	  when 1 then o1:=2; o2:=3;
	  when 2 then o1:=1; o2:=3;
	  when 3 then o1:=1; o2:=2;
	end case;
	rk := (3*(i-1))+r;
	dbms_output.put_line('rk='||rk);
    for c in 1..9 loop
	  if sudoku_square_b(i)(j).row(r)(c) and not ((sudoku_square_b(i)(j).row(o1)(c)) or (sudoku_square_b(i)(j).row(o2)(c))) then
	    k:= (3*(j-1))+1;
		for kol in 1..k-1 loop
		  if board(rk)(kol).p_list(c) then
	        dbms_output.put_line('***** '||c||' blocking row '||rk);		  
		    dbms_output.put_line('LEFT: '||c||' not possible at ('||rk||','||kol||')');
		    board(rk)(kol).p_list(c) := false;
			board(rk)(kol).nb_poss := board(rk)(kol).nb_poss-1;			  
			changes := true;  
		  end if;
		end loop;
		for kol in k+3..9 loop
		  if board(rk)(kol).p_list(c) then
	        dbms_output.put_line('***** '||c||' blocking row '||rk);
		    dbms_output.put_line('RIGHT: '||c||' not possible at ('||rk||','||kol||')');
		    board(rk)(kol).p_list(c) := false;
			board(rk)(kol).nb_poss := board(rk)(kol).nb_poss-1;
			--HUSK vi skal også sætte c som umulig i sudoku_square_b !!!!!!!!!!!!!!!!!!!!!!!!!!!!			
			changes := true;  
		  end if;		
		end loop;
	  end if;
    end loop;
  end loop;
  dbms_output.put_line('horizontalObstructingElements ok');
  return changes;
end horizontalObstructingElements;

function verticalObstructingElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board, i in number, j in number) return boolean
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
  o1 number :=0;
  o2 number :=0;
  clmn number :=0;
  r number := 0;
begin
  dbms_output.put_line('verticalObstructingElements begin square=('||i||','||j||')');
  for cl in 1..3 loop
    case cl
	  when 1 then o1:=2; o2:=3;
	  when 2 then o1:=1; o2:=3;
	  when 3 then o1:=1; o2:=2;
	end case;
	clmn := (3*(j-1))+cl;
	dbms_output.put_line('clmn='||clmn);
    for c in 1..9 loop
	  if sudoku_square_b(i)(j).col(cl)(c) and not ((sudoku_square_b(i)(j).col(o1)(c)) or (sudoku_square_b(i)(j).col(o2)(c))) then
	    r:= (3*(i-1))+1;
		for rk in 1..r-1 loop
		  if board(rk)(clmn).p_list(c) then
	        dbms_output.put_line('***** '||c||' blocking column '||clmn);
		    dbms_output.put_line('UPPER: '||c||' not possible at ('||rk||','||clmn||')');
		    board(rk)(clmn).p_list(c) := false;
			board(rk)(clmn).nb_poss := board(rk)(clmn).nb_poss-1;
			changes := true;  
		  end if;
		end loop;
		for rk in r+3..9 loop
		  if board(rk)(clmn).p_list(c) then
	        dbms_output.put_line('***** '||c||' blocking column '||clmn);
		    dbms_output.put_line('LOWER: '||c||' not possible at ('||rk||','||clmn||')');
		    board(rk)(clmn).p_list(c) := false;
			board(rk)(clmn).nb_poss := board(rk)(clmn).nb_poss-1;
			changes := true;  
		  end if;		
		end loop;
	  end if;
    end loop;
  end loop;
  dbms_output.put_line('verticalObstructingElements ok');
  return changes;
end verticalObstructingElements;


function horizontalSquareElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board, i in number, j in number) return boolean
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
  o1 number :=0;
  o2 number :=0;
  rk number :=0;
  r number := 0;
  x number := 0;
  y number := 0;
begin
  dbms_output.put_line('horizontalSquareElements begin square=('||i||','||j||')');
  case i
    when 1 then x:=1;
	when 2 then x:=4;
	when 3 then x:=7;
  end case;
  case j
    when 1 then y:=1;
	when 2 then y:=4;
	when 3 then y:=7;
  end case;
 
  for squareRow in 1..3 loop
    case squareRow
	  when 1 then o1:=2; o2:=3;
	  when 2 then o1:=1; o2:=3;
	  when 3 then o1:=1; o2:=2;
	end case;
	rk := (3*(i-1))+squareRow;
	dbms_output.put_line('rk='||rk);
    for c in 1..9 loop
	  if sudoku_square_b(i)(j).row(squareRow)(c) and not ((sudoku_square_b(i)(o1).row(squareRow)(c)) or (sudoku_square_b(i)(o2).row(squareRow)(c))) then
	    --Nu skal vi fjerne c som mulighed i kvadrat (i,j), dog ikke i række squareRow lokalt, (eller række rk globalt).
	    for x1 in x..x+2 loop
		  for y1 in y..y+2 loop
		    if board(x1)(y1).p_list(c) and x1<>rk then
		      dbms_output.put_line('SQUARE: '||c||' not possible at ('||x1||','||y1||')');			
			  board(x1)(y1).p_list(c) := false;
			  board(x1)(y1).nb_poss := board(x1)(y1).nb_poss-1;
			  changes := true;
			end if; 
		  end loop;
		end loop;	
	  end if;
    end loop;
  end loop;
  dbms_output.put_line('horizontalSquareElements ok');
  return changes;
end horizontalSquareElements;


function verticalSquareElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board, i in number, j in number) return boolean
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
  o1 number :=0;
  o2 number :=0;
  clmn number :=0;
  x number := 0;
  y number := 0;
begin
  dbms_output.put_line('verticalSquareElements begin square=('||i||','||j||')');
  case i
    when 1 then x:=1;
	when 2 then x:=4;
	when 3 then x:=7;
  end case;
  case j
    when 1 then y:=1;
	when 2 then y:=4;
	when 3 then y:=7;
  end case;
 
  for cl in 1..3 loop
    case cl
	  when 1 then o1:=2; o2:=3;
	  when 2 then o1:=1; o2:=3;
	  when 3 then o1:=1; o2:=2;
	end case;
	clmn := (3*(j-1))+cl;
	dbms_output.put_line('clmn='||clmn);
    for c in 1..9 loop
	  if sudoku_square_b(i)(j).col(cl)(c) and not ((sudoku_square_b(o1)(j).col(cl)(c)) or (sudoku_square_b(o2)(j).col(cl)(c))) then
	    --Nu skal vi fjerne c som mulighed i kvadrat (i,j), dog ikke i kolonne cl lokalt, (eller kolonne clmn globalt).
	    for x1 in x..x+2 loop
		  for y1 in y..y+2 loop
		    if board(x1)(y1).p_list(c) and y1<>clmn then
		      dbms_output.put_line('SQUARE: '||c||' not possible at ('||x1||','||y1||')');			
			  board(x1)(y1).p_list(c) := false;
			  board(x1)(y1).nb_poss := board(x1)(y1).nb_poss-1;
			  changes := true;
			end if; 
		  end loop;
		end loop;	
	  end if;
    end loop;
  end loop;
  dbms_output.put_line('verticalSquareElements ok');
  return changes;
end verticalSquareElements;

function ObstructingElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board, i in number, j in number) return boolean
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
begin
  if horizontalObstructingElements(board, sudoku_square_b, i,j) then
    changes := true;
  end if;
  if not changes then
    if verticalObstructingElements(board, sudoku_square_b, i,j) then
	  changes := true;
	end if;
  end if;
  return changes;
end ObstructingElements;

function removeSquareElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board, i in number, j in number) return boolean
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
begin
  if horizontalSquareElements(board, sudoku_square_b,i,j) then
    changes := true;
  end if;
  if not changes then
    if verticalSquareElements(board, sudoku_square_b,i,j) then
	  changes := true;
	end if;
  end if;
  return changes;
end removeSquareElements;


function obstructingElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board) return boolean 
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
begin
  for i in 1..3 loop
    for j in 1..3 loop
	  if obstructingElements(board, sudoku_square_b, i,j) then
	    changes := true;
	  end if;
	end loop;
  end loop;
  return changes;
end obstructingElements;

function removeSquareElements(board IN OUT sudoku_board, sudoku_square_b IN sudoku_square_board) return boolean 
  --Arbejder på datastrukturen board.
is
  changes boolean := false;
begin
  for i in 1..3 loop
    for j in 1..3 loop
	  if removeSquareElements(board, sudoku_square_b, i,j) then
	    changes := true;
	  end if;
	end loop;
  end loop;
  return changes;
end removeSquareElements;


procedure solveSudoku(board IN OUT sudoku_board, sudoku_square_b IN OUT sudoku_square_board)
  --Arbejder på datastrukturerne board og sudoku_board_b
is
  changes boolean := TRUE;
  boardCompleted boolean := false;
begin
  while changes loop
    changes := false;
	for i in 1..9 loop
	  for j in 1..9 loop
	    for c in 1..9 loop
		  if markable(board, i,j,c) then
		    dbms_output.put_line('Marking ('||i||','||j||')='||c);
			--Return after having found the next hole to fill out.
			--return;
		    board(i)(j).content := c;
			--No values for field board(i)(j) are possible anymore.
			board(i)(j).nb_poss:=0;
			for ch in 1..9 loop
			  board(i)(j).p_list(ch) := false;
			end loop;
			removeRowPossibilities(board, sudoku_square_b, i,c); --This call will adjust also the board of squares regarding the row i.
			removeColumnPossibilities(board, sudoku_square_b, j,c); --This call will adjust also the board of squares regarding the column j. 
			removeSquarePossibilities(board, sudoku_square_b, i,j,c);--This call will adjust also the board of squares.
			--Kald en procedure som gør fgl. for hvert 3x3 kvadrat sæt alle muligheder falsk.
			--for hver række i kvadratet, for hvert felt, hvis et ciffer c er muligt så sæt det muligt i kvadrat rækken.
			--for hver kolonne i kvadratet, for hvert felt, hvis et ciffer c er muligt så sæt det muligt i kvadrat kolonnen.
			--På denne måde sikrer vi, at der er konsistens mellem sudoku_poss_board og sudoku_square_board. 		
			updateSquareBoard(board, sudoku_square_b);	
			changes:=true;
		  end if;
		end loop;
	  end loop;
	end loop;
	boardCompleted := checkSudokuBoard(board);
	if not boardCompleted then 
	  if not changes then
	    if removeSquareElements(board, sudoku_square_b) then
		  changes := true;
		end if;
	  end if;
	  if not changes then 
	    if siblingsFound(board) then
	      changes:=true;
		  updateSquareBoard(board, sudoku_square_b);
	    end if;
	  end if;
	  if not changes then
	    if obstructingElements(board, sudoku_square_b) then
	      changes := true;
		  updateSquareBoard(board, sudoku_square_b);
	    end if;
	  end if;
	  if not changes then
	    if hiddenPairs(board) then
	      changes := true;
		  updateSquareBoard(board, sudoku_square_b);
	    end if;
	  end if;

	  if not changes then
	    if XWing(board) then
	      changes := true;
		  updateSquareBoard(board, sudoku_square_b);
	    end if;
	  end if;	  	  

	end if;
  end loop;
end solveSudoku;

--If a sudoku has an empty field, for which there are NO possible values, the sudoku is 
--said to be inconsistent.  
function inconsistentSudoku(board IN sudoku_board) return boolean
is
  occurences number;
  noOccurence boolean;
  i number; j number; x number; y number;
begin
  --If an empty field has no possible values the board is inconsistent.
  for i in 1..9 loop
    for j in 1..9 loop
	  if board(i)(j).content is null then
	    if not (board(i)(j).p_list(1) or board(i)(j).p_list(2) or board(i)(j).p_list(3) or 
		        board(i)(j).p_list(4) or board(i)(j).p_list(5) or board(i)(j).p_list(6) or 
				board(i)(j).p_list(7) or board(i)(j).p_list(8) or board(i)(j).p_list(9)) then
		  dbms_output.put_line('Sudoku INCONSISTENT!!');
		  return true;
		end if;
	  end if;
	end loop;
  end loop;
  
  --If a value is missing, and also not possible in a row, column or square the board is inconsistent.
  for i in 1..9 loop
    for c in 1..9 loop
	  
	  --Check for no occurence of digit c in row i.
	  noOccurence := TRUE;
	  for j in 1..9 loop
	    if board(i)(j).content=c OR board(i)(j).p_list(c) then
		  noOccurence:=FALSE;
		end if;		  
	  end loop;
	  if noOccurence then
	    dbms_output.put_line('Sudoku INCONSISTENT!!');
	    return true;
	  end if;
	  
	  --Check for no occurence of digit c in column j.
	  noOccurence := TRUE;
	  for j in 1..9 loop
	    if board(j)(i).content=c OR board(j)(i).p_list(c) then
		  noOccurence:=FALSE;
		end if;		  
	  end loop;
	  if noOccurence then
	    dbms_output.put_line('Sudoku INCONSISTENT!!');
        return true;
	  end if;
	  
	end loop;
  end loop;
    
  i:=1;
  j:=1;
  for c in 1..9 loop
    while i<9 loop
      while j<9 loop
        noOccurence := TRUE;
	    x:=i;
	    while x<i+3 loop
	      y:=j;
	      while y<j+3 loop
		    if board(x)(y).content=c OR board(x)(y).p_list(c) then
		      noOccurence:=FALSE;
		    end if;
		    y:=y+1;
		  end loop;
		  x:=x+1;
	    end loop;
	    j:=j+3;
		if noOccurence then
	      dbms_output.put_line('Sudoku INCONSISTENT!!');
		  return true;		
		end if;
	  end loop;
	  i:=i+3;
    end loop;
  end loop;
    
  --If a digit is present more than once in a row, column or square the board is inconsistent.
  for i in 1..9 loop
    for c in 1..9 loop

      occurences:=0;
      for j in 1..9 loop
	    if board(i)(j).content=c then
	      occurences:=occurences+1;
		end if;
	  end loop;
	  if occurences>1 then
 	    dbms_output.put_line('Sudoku INCONSISTENT!!');
	    return true;
	  end if;

      occurences:=0;
      for j in 1..9 loop
	    if board(j)(i).content=c then
	      occurences:=occurences+1;
		end if;
	  end loop;
	  if occurences>1 then
	    dbms_output.put_line('Sudoku INCONSISTENT!!');
        return true;
	  end if;

	end loop;
  end loop;

  i:=1;
  j:=1;
  while i<9 loop
    j:=1;
    while j<9 loop
      for c in 1..9 loop
--	    dbms_output.put_line('c='||c);
	    occurences:=0;
	    x:=i;
        while x<i+3 loop
	      y:=j;
	      while y<j+3 loop
		 --   dbms_output.put_line('x='||x||', y='||y);
		    if board(x)(y).content=c  then
	          occurences:=occurences+1;
		    end if;
		    y:=y+1;
		  end loop;
		  x:=x+1;
	    end loop;
		if occurences>1 then
	      dbms_output.put_line('Sudoku INCONSISTENT!!');
		  return true;		
		end if;
	  end loop;
--	  dbms_output.put_line('OK j !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');	  
	  j:=j+3;
    end loop;
--	dbms_output.put_line('OK i !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    i:=i+3;
  end loop;
  
  --If the board is not found inconsistent, it must be consistent.
  return false;
end inconsistentSudoku;

--Function makeGuess finds the first empty field and iteratively tries out its possible values knowing
--well that only one of these is the correct one. When a vaule v is assigned to an empty board field (i,j) there are 
--no less than three possible outcomes:
--	 1) The sudoku is solved, and consequently the guess v was successfull for field (i,j). 
--	 2) The sudoku is isconsistent, and consequently the guess was v definetely not succesfull for field (i,j).
--	 3) The sudoku is not yet solved but not inconsistent either, consequently it is not conclusive 
--      if the value v is succesfull for field (i,j) or not. Now, makeGuess calls itself recursively hereby starting to 
--      guess a value v' for the next empty field, still having (i,j)=v.
function makeGuess(board IN OUT sudoku_board, sudoku_square_b IN OUT sudoku_square_board) return boolean
is
  rem_board sudoku_board;
  rem_square_board sudoku_square_board;
  i number; j number; c number;
  result boolean := false;
begin
  rem_board        := board;
  rem_square_board := sudoku_square_b;
  for i in 1..9 loop
    for j in 1..9 loop
	  if board(i)(j).content is null then
	    dbms_output.put_line('Set value for field ('||i||','||j||')');
		dbms_output.put_line('Possible values :');
		for c in 1..9 loop
		  if board(i)(j).p_list(c) then
		    dbms_output.put_line(c||' ');
		  end if;
		end loop;
	    c:=1;
	    while (not result) and c<=9 loop
		  if board(i)(j).p_list(c) then
		    dbms_output.put_line('Trying value '||c);
		    board:=rem_board;
			sudoku_square_b:=rem_square_board;
			board(i)(j).content:=c;
			board(i)(j).nb_poss:=0;
			for ch in 1..9 loop
			  board(i)(j).p_list(ch) := false;
			end loop;
			removeRowPossibilities(board, sudoku_square_b, i,c); --This call will adjust also the board of squares regarding the row i.
			removeColumnPossibilities(board, sudoku_square_b, j,c); --This call will adjust also the board of squares regarding the column j. 
			removeSquarePossibilities(board, sudoku_square_b, i,j,c);--This call will adjust also the board of squares.
			updateSquareBoard(board, sudoku_square_b);	
			solveSudoku(board, sudoku_square_b);
            if sudoku.checkSudokuBoard(BOARD) then
              dbms_output.put_line('OK to put '||c||' at position ('||i||','||j||')');
			  return true;
            elsif sudoku.inconsistentSudoku(BOARD) then  	
              dbms_output.put_line('NOT OK to put '||c||' at position ('||i||','||j||')');
		      board:=rem_board;
			  sudoku_square_b:=rem_square_board;
			else --Not solved but still consistent, need to perform further guessing.
              dbms_output.put_line('Perhaps ok to put '||c||' at position ('||i||','||j||')');
			  result:=makeGuess(board, sudoku_square_b);
			  if result then return true; end if;
		      board:=rem_board;
			  sudoku_square_b:=rem_square_board;
            end if;
		  end if;
		  c:=c+1;
		end loop;
		return result;
	  end if;
	end loop;
  end loop;
end makeGuess;

procedure play is
  x number;
  BOARD       sudoku_board;
  SQUARE_BOARD    sudoku_square_board;
  result boolean;  
begin
  null;
  --Opret sudoku bræt. 
  BOARD := SUDOKU_BOARD();
  SQUARE_BOARD := SUDOKU_SQUARE_BOARD();
  begin 
    sudoku.createSudokuBoard(BOARD, SQUARE_BOARD); 
  end;
  
  --Udfyld sudoku bræt.
  sudoku.fillSudokuBoard(BOARD, SQUARE_BOARD);

  --Udskriv bræt, muligheder og kvadratmuligheder.
  sudoku.printBoard(BOARD);

  sudoku.printPossBoard(BOARD);
  
  if sudoku.inconsistentSudoku(BOARD) then
    return;
  end if;

  sudoku.printSquareBoard(SQUARE_BOARD);

  sudoku.solveSudoku(BOARD, SQUARE_BOARD);
  --Return after having filled the next empty field.
--  return;

  sudoku.printBoard(BOARD);

  sudoku.printPossBoard(BOARD);
  
  if sudoku.checkSudokuBoard(BOARD) then
    dbms_output.put_line('OK');
  else
    --Opdater kvadratbrædtet.
    updateSquareBoard(BOARD, SQUARE_BOARD);
    result:=sudoku.makeGuess(BOARD, SQUARE_BOARD);
    --Hvis der overhovedet findes en løsning, så er den nu fundet. 

    sudoku.printBoard(BOARD);
	
    if sudoku.checkSudokuBoard(BOARD) then
      dbms_output.put_line('OK');
    else
      dbms_output.put_line('Not a solution.');
    end if;
  end if;
end play;

procedure printBoard(board IN sudoku_board) is
--Arbejder på board
begin
  for r in 1..9 loop
    --dbms_output.put('|');
    if mod(r,3)=1 then dbms_output.put_line('--------------------'); end if;
    for c in 1..9 loop
	  if mod(c,3)=1 then dbms_output.put('|'); end if; 
      if board(r)(c).content is not null then
	    dbms_output.put(board(r)(c).content||' ');
	  else
	    dbms_output.put('  ');
	  end if;
	end loop;
	dbms_output.put_line(' ');
  end loop;
end printBoard;

procedure printPossBoard(board IN sudoku_board) is
--Arbejder på board
begin
  dbms_output.put_line('Printing Board of Possibilities:');
/*  for r in 1..9 loop
    if mod(r,3)=1 then dbms_output.put_line('--------------------'); end if;
    for c in 1..9 loop
      if mod(c,3)=1 then dbms_output.put('|'); end if; 
      dbms_output.put(board(r)(c).nb_poss);
      dbms_output.put(':[');
      for p in 1..9 loop
        if board(r)(c).p_list(p) and board(r)(c).content is null then
           dbms_output.put(p||',');
        end if;
      end loop;
      dbms_output.put(']');
    end loop;
    dbms_output.put_line(' ');
  end loop;
*/
  for r in 1..9 loop
    IF MOD(R,3) = 1 THEN dbms_output.put_line('+---------+---------+---------+---------+---------+---------+---------+---------+---------+');
	ELSE                 dbms_output.put_line('+         +         +         +         +         +         +         +         +         +');
	end if;                     
    for c in 1..9 loop
      IF MOD(C,3) = 1 THEN dbms_output.put('|'); 
	  ELSE                 dbms_output.put(' ');
	  END IF;
  ---    dbms_output.put(board(r)(c).nb_poss);
      for p in 1..9 loop
        if board(r)(c).p_list(p) and board(r)(c).content is null then
           dbms_output.put(p);
        else
           dbms_output.put(' ');
        end if;
      end loop;
    end loop;
    dbms_output.put_LINE('|');
  end loop;
  dbms_output.put_line('+---------+---------+---------+---------+---------+---------+---------+---------+---------+');
end printPossBoard;

procedure printSquareBoard(sudoku_square_b IN sudoku_square_board) is
--Arbejder på sudoku_square_b
begin
  Dbms_output.put_line('Printing Board of Squares:');
  for i in 1..3 loop
    for j in 1..3 loop
      dbms_output.put_line('Square ('||i||','||j||')');
	  dbms_output.put_line('          +---------+---------+---------+');
	  dbms_output.put('          |');
      for p in 1..3 loop
  --      dbms_output.put('Col: '||p||': [');
        for c in 1..9 loop
          if sudoku_square_b(i)(j).col(p)(c) then
            dbms_output.put(c);
          ELSE
		    dbms_output.put(' ');
          end if;
        end loop;
        dbms_output.put('|');
      END LOOP;
	  dbms_output.put_line(' ');
--        dbms_output.put(']  ');
	  dbms_output.put_line('+---------+---------+---------+---------+');
      for p in 1..3 loop
	    dbms_output.put('|');
        for c in 1..9 loop
          if sudoku_square_b(i)(j).row(p)(c) then
            dbms_output.put(c);
          ELSE
		    DBMS_OUTPUT.PUT(' ');
          end if;
        end loop;
		dbms_output.put_line('|');
        dbms_output.put_line('+---------+');
      end loop;
      end loop;
    end loop;
 end printSquareBoard;
 
/*
procedure printSquareBoard is
begin
  Dbms_output.put_line('Printing Board of Squares:');
  for i in 1..3 loop
    for j in 1..3 loop
      dbms_output.put_line('Square ('||i||','||j||')');
		for p in 1..3 loop
	      dbms_output.put('Row: '||p||': [');
	      for c in 1..9 loop
	        if sudoku_square_b(i)(j).row(p)(c) then
	          dbms_output.put(c||',');
		    end if;
		  end loop;
	      dbms_output.put(']  ');
	    end loop;
		dbms_output.put_line(' ');
		for p in 1..3 loop
	      dbms_output.put('Col: '||p||': [');
	      for c in 1..9 loop
	        if sudoku_square_b(i)(j).col(p)(c) then
	          dbms_output.put(c||',');
		    end if;
		  end loop;
	      dbms_output.put(']  ');
	    end loop;
		dbms_output.put_line(' ');
	end loop;
	dbms_output.put_line('--------------------');
  end loop;
 end printSquareBoard;
*/

procedure updateSquareBoard(board IN sudoku_board, sudoku_square_b IN OUT sudoku_square_board)
--Arbejder på board OG sudoku_square_b 
is
  x number;
  y number;
  x2 number;
  y2 number;
begin
  --First, set all square possibilities false 
  for i in 1..3 loop
    for j in 1..3 loop
	  for r in 1..3 loop
	    for c in 1..9 loop
	      sudoku_square_b(i)(j).row(r)(c):= false;
	      sudoku_square_b(i)(j).col(r)(c):= false;
		end loop;
	  end loop;
	end loop;
  end loop;
  --Then, loop through the 81 board squares. For each field (i,j), if c is possible then it must
  --be set possible in the corresponding row and column in the square that it belongs to.
  for i in 1..3 loop
    for j in 1..3 loop
	  x:=3*(i-1)+1;
	  y:=3*(j-1)+1;
	  for x1 in x..x+2 loop
	    for y1 in y..y+2 loop
		  for c in 1..9 loop
		    if board(x1)(y1).p_list(c) then
			  x2:=mod(x1,3); if x2=0 then x2:=3; end if;
			  y2:=mod(y1,3); if y2=0 then y2:=3; end if;
			  sudoku_square_b(i)(j).row(x2)(c):= true;
			  sudoku_square_b(i)(j).col(y2)(c):= true;
			end if;			  
		  end loop;
		end loop;
	  end loop;
	end loop;
  end loop;
end updateSquareBoard;

end sudoku;
/
show errors;

