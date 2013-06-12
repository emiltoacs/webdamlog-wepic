peer sigmod_peer = localhost:4100;
peer local = localhost:5100;
collection ext per picture@local(title*, owner*, _id*, image_url*); #image data fields not added
collection ext per picturelocation@local(_id*, location*);
collection ext per rating@local(_id*, rating*);
collection ext per comment@local(_id*,author*,text*,date*);
collection ext per contact@local(username*, peerlocation*, online*, email*, facebook*);
fact contact@local(Jules, SIGMOD_peer, false, "jules.testard@mail.mcgill.ca", "Jules Testard");
fact contact@local(Julia, SIGMOD_peer, false, "stoyanovich@drexel.edu", "jstoy");
rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
end