peer sigmod_peer = localhost:4100;
collection ext persistent picture@local(title*, owner*, _id*, image_url*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact contact@local(Jules, "127.0.0.1", 4100, false, "jules.testard@mail.mcgill.ca");
fact contact@local(Julia, "127.0.0.1", 4150, false, "stoyanovich@drexel.edu");
rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
end