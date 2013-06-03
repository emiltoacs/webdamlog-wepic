peer emilien=localhost:12345;
peer julia=localhost:12346;
peer serge=localhost:12347;
collection ext persistent child@emilien(child*,father*,mother*);
collection int direct_child@emilien(child*,parent*);
collection int descendant@emilien(child*,parent*);
fact child@emilien(e,F,M);
fact child@emilien(E,F,M);
fact child@emilien(F,FF,MF);
rule direct_child@emilien($a,$b):-child@emilien($a,$b,_);
rule direct_child@emilien($a,$b):-child@emilien($a,_,$b);
rule child@emilien($x,$y,$z):-child@julia($x,$y,$z);
end
