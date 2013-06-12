peer sigmod_peer = localhost:4100;
peer local = localhost:4150;
collection ext persistent picture@local(title*, owner*, _id*, image_url*); #image data fields not added  
collection ext persistent picture_location@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, peerlocation*, online*, email*, facebook*);
fact contact@local(Jules, localhost:4100, false, "jules.testard@mail.mcgill.ca", "Jules Testard");
fact contact@local(Julia, localhost:4100, false, "stoyanovich@drexel.edu", "jstoy");
rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
end