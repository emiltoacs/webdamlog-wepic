peer sigmod_peer = localhost:10000;
collection ext persistent contact@local(username*, peerlocation*, online*, email*, facebook*);
fact ext per contact@local(sigmod_peer, localhost:10000, false, none, none);
end