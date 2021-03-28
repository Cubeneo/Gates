Program The_Gates ;

{$mode objfpc}{$H-}{$J+}

//Uses gvector ;
Uses math, Crt ;

Const
        empty = -1 ;
	max_Num = 10 ;
	input_Gate = 0 ;  output_Gate = 1 ;
	  not_Gate = 2 ;      or_Gate = 3 ;
	  and_Gate = 4 ;
Const
	truth_Table : Array [0..4, 0..1, 0..1] of Byte
                = (((0,0),
				    (1,1)),
				   ((0,0),
				    (1,1)),
				   ((1,1),
				    (0,0)),
				   ((0,1),
				    (1,1)),
				   ((0,0),
				    (0,1)));

Type
    //vector_int = specialize TVector<Longint> ;
	Tgate = Class
				//public
					id : Longint ; gate_Type : Byte ;
					input_A, input_B : Byte ;
					link_A, Link_B : Longint ;
					output_S : Byte ;
					link_Out : Array [0..max_Num] of Byte ;
                    constructor create(_id : Longint; gT : Byte) ; overload ;
					destructor destroy ; overload ;
					Procedure set_input_A(from : Longint) ;
					Procedure set_input_B(from : Longint) ;
					Procedure set_Output_S(link_to : longint; A_B : Byte);
					Procedure Fresh ;
			End;

Var
	 chip : Array [1..10,1..10] of Longint ;
	gates : Array [0..max_Num]  of   Tgate ;
Var tot : Longint = 1 ;
	exist : Array [0..max_Num] of Byte ;
Var cmd, line : String ; ch : Char ; args : Longint ;

Constructor Tgate.create (_id : longint ; gT : Byte ) ;
Begin
    if tot < _id then tot := _id ;
	exist[_id] := 1 ;
	id := _id ;
	gate_Type := gT ;
	input_A := 0 ;
    link_A := 0 ;
	input_B := 0 ;
    link_B := 0 ;
	output_S := 0 ;
	fillChar(link_Out,sizeof(link_Out),0);
End;

destructor Tgate.destroy ;
Begin
	if id=tot then dec(tot) ;
	exist[id] := 0 ;
End;

Procedure Tgate.set_input_A (from : Longint);
Begin
    if exist[from] = 0 then exit ;
	if exist[link_A] = 1 then gates[link_A].link_Out[id] := 0 ;
	link_A := from ;
	gates[from].link_Out[id] := 1 ;
	fresh ;
End;

Procedure Tgate.set_input_B (from : Longint) ;
Begin
    if exist[from] = 0 then exit ;
	if exist[link_B] = 1 then gates[link_B].link_Out[id] := 0 ;
	link_B := from ;
	gates[from].link_Out[id] := 1 ;
	fresh ;
End;

Procedure Tgate.set_Output_S (link_to : Longint; A_B : Byte) ;
Begin
	Case A_B of
		0 : gates[link_to].set_input_A(id);
		1 : gates[link_to].set_input_B(id);
	End;
End;

Procedure Tgate.Fresh ;
var i : longint ;
Begin
	if gate_Type<>input_Gate
		then Begin
			if exist[link_A]=1
				then input_A := gates[link_A].output_S
				else Begin input_A := 0 ; link_A := 0 ; End;
		End;
	if exist[link_B]=1
		then input_B := gates[link_B].output_S
		else Begin input_B := 0 ; link_B := 0 ; End ;
	if (gate_Type=output_Gate) or (truth_Table[gate_Type,input_A,input_B]=output_S) then exit ;
	output_S := truth_Table[gate_Type,input_A,input_B] ;
	For i := 1 to tot do
		Begin
			if link_Out[i]=1
				then Begin
						gates[i].fresh ;
				End;
		End;
End;

Procedure initGates ;
Begin
	fillChar(exist,sizeof(exist),0);
	fillChar(chip,sizeof(chip),0);
	gates[0] := Tgate.create(0,255) ;
End;

Procedure click;
Var _id_ : Longint ;
Begin
	//writeln('At Func click.');
    Readln(_id_);
	//id := 1 ;
	if exist[_id_]=0 then exit ;
	//writeln('Step 1.');
	if gates[_id_].gate_Type<>0 then exit ;
	//writeln('Step 2.');
	gates[_id_].input_A := byte(gates[_id_].input_A=0) ;
	writeln('#',_id_,' turn to ',gates[_id_].input_A);
	gates[_id_].Fresh ;
	//writeln('Step 3.');
End;

Procedure list ;
Var gT : Byte ; i : Longint ;
Begin
	//writeln('At Func list.');
	Readln(gT);
	//gT := output_Gate ;
	For i := 1 to tot do
		if (exist[i]=1) and (gates[i].gate_Type=gT)
			then Begin
				write('#',gates[i].id,' ',gates[i].gate_Type);
				if (gates[i].gate_Type=input_Gate) or
					(gates[i].gate_Type=output_Gate)
					then Begin
							if gates[i].input_A=0
								then writeln(' -')
								else writeln(' *');
					End else Writeln;
			End;
End;

Procedure list_All ;
Var gT : Byte ; i : Longint ;
Begin
	//writeln('At Func list.');
	//Readln(gT);
	//gT := output_Gate ;
	For i := 1 to tot do
		if (exist[i]=1)
			then Begin
				write('#',gates[i].id,' ',gates[i].gate_Type);
				if (gates[i].gate_Type=input_Gate) or
					(gates[i].gate_Type=output_Gate)
					then Begin
							if gates[i].input_A=0
								then writeln(' -')
								else writeln(' *');
					End else Writeln;
			End;
End;

Procedure new ;
Var i : Longint = 1 ; gT : Byte ;
Begin
	readln(gT);
	while exist[i]=1 do inc(i);
	gates[i] := Tgate.create(i,gT);
End;

Procedure del ;
Var id : longint ;
Begin
	Readln(id);
	if exist[id]=1 then gates[id].destroy ;
End;

Procedure linkto;
{把from的输出连接到id的A_B输入端上}
Var id : Longint ; A_B : byte ; from : Longint ;
Begin
	Readln(id,A_B,from);
	if (exist[id]=1) and (exist[from]=1)
		then if A_B = 0
				then gates[id].set_input_A(from)
				else gates[id].set_input_B(from) ;
End;

Procedure cut ;
{剪断id的A_B输入端口}
Var id : Longint ; A_B : Byte ;
Begin
	Readln(id,A_B);
	if exist[id]=1
		then if A_B = 0
				then Begin
					gates[id].set_input_A(0);
				End else Begin
					gates[id].set_input_B(0);
				End;
End;

Begin
	initGates ;
	{gates[1]:=Tgate.create(1,input_Gate);
	gates[2]:=Tgate.create(2,input_Gate);
	gates[3]:=Tgate.create(3,input_Gate);
	gates[4]:=Tgate.create(4,and_Gate);
	gates[5]:=Tgate.create(5,or_Gate);
	gates[6]:=Tgate.create(6,output_Gate);
	gates[6].set_input_A(4);
	gates[4].set_input_A(1);
	gates[4].set_input_B(5);
	gates[5].set_input_A(2);
	gates[5].set_input_B(3);}
	while true do
		Begin
			write('>>');
			line := '' ;
			ch := '@' ;
			while true do
				Begin
					ch:=readkey;
					case ord(ch) of
						8 : if length(line)>0  //退格键
								then Begin
									delete(line,length(line),1);
									gotoxy(wherex-1,wherey);
									write(' ');
									gotoxy(wherex-1,wherey);
								end;
						ord(' ') :  //空格，带参数命令
							Begin
								write(ch);
								cmd := line ;
								if cmd='new' then new() ;
								if cmd='del' then del() ;
								if cmd='linkto' then linkto() ;
								if cmd='cut' then cut() ;
								if cmd='click' then click() ;
								if cmd='list' then list() ;
								if cmd='exit' then exit ;
								cmd := '' ;
								break;
								//args := get_arg ;
							End;
						13 :  //回车，短命令
							Begin
								writeln ;
								cmd := line ;
								if cmd='list' then list_All ;
								if cmd='exit' then exit ;
								cmd := '' ;
								break;
							End;
						else Begin
							line := line + lowercase(ch) ;
							write(ch);
						End;  // end else 
					End;  //end case
				End; //end while 
		End;
End.
