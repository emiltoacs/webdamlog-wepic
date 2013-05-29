peer sigmod_peer = localhost:4100;
//collection ext persistent picture@local(title*, owner*); //image data fields not added 
//collection ext persistent picturelocation@local(title*, owner*, location*);
//collection ext persistent rating@local(title*, owner*, rating*);
//collection ext persistent comment@local(title*, owner*, body*); //refers to title of picture, not title of comment
collection ext persistent contact@local(username*, peerlocation*, online*, email*, facebook*);
rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
end