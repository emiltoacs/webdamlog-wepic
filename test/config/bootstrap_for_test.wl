peer sigmod_peer = localhost:4100;
peer local = localhost:5100;
collection ext persistent picture@local(title*, owner*, _id*, image_url*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, peerlocation*, online*, email*, facebook*);
rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
end