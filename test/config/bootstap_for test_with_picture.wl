peer sigmod_peer = localhost:4100;
collection ext persistent picture@local(title*, owner*, _id*, image_url*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact contact@local(Jules, "127.0.0.1", 4100, false, "jules.testard@mail.mcgill.ca");
fact contact@local(Julia, "127.0.0.1", 4150, false, "stoyanovich@drexel.edu");
fact picture@local(sigmod,Jules,12347,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(webdam,Julia,12348,"http://www.cs.tau.ac.il/workshop/modas/webdam3.png");
fact picture@local(me,Jules,12349,"http://www.cs.mcgill.ca/~jtesta/images/profile.png");
rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
end