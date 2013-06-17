peer sigmod_peer = localhost:4100;
collection ext persistent picture@local(title*, owner*, _id*, image_url*, date*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact picture@local(sigmod,Jules,12345,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(sigmod,Julia,12346,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(sigmod,Jules,12347,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(webdam,Jules,12348,"http://www.cs.tau.ac.il/workshop/modas/webdam3.png");
fact picture@local(me,Jules,12349,"http://www.cs.mcgill.ca/~jtesta/images/profile.png");
fact picture@local(me,Julia,12350,"http://www.cs.columbia.edu/~jds1/pic_7.jpg");
fact picture@local(me,Julia,12351,"http://www.cs.tau.ac.il/workshop/modas/julia.png");
#Custom content
collection ext persistent person@local(_id*,name*);
collection ext persistent friend@local(_id1*,_id2*);
fact person@local(12345,oscar);
fact person@local(12346,hugo);
fact person@local(12347,kendrick);
fact friend@local(12345,12346);
fact friend@local(12346,12347);

fact location@local(12345,"New York");
fact location@local(12346,"New York");
fact location@local(12347,"New York");
fact location@local(12348,"Paris, France");
fact location@local(12349,"McGill University");
fact location@local(12350,"Columbia");
fact location@local(12351,"Tau workshop");

fact rating@local(12345,5,Jules);
fact rating@local(12349,5,Julia);

fact contact@local(Jules, 127.0.0.1, 4100, false, "jules.testard@mail.mcgill.ca");
fact contact@local(Julia, 12.0.0.1, 4150, false, "stoyanovich@drexel.edu");

rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
rule person@local($id,$name) :- friend@local($id,$name);
end