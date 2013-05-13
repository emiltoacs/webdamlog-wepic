collection ext persistent contact@local(username*, peerlocation*, online*, email*, facebook*);
collection ext persistent pet@local(name*,animal_type*,age*,sex*);
fact contact@local(fakebootstrappeername, localhost:10000, false, none, none);
fact pet@local(bilou,dog,3,male);
end