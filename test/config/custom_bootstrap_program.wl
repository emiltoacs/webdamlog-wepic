peer sigmod_peer = localhost:4100;
collection ext persistent picture@local(title*, owner*, _id*, image_url*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, peerlocation*, online*, email*, facebook*);
collection ext persistent describedrule@local(wdlrule*, description*);
fact picture@local(sigmod,Jules,12345,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(sigmod,Julia,12346,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(sigmod,local,12347,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(webdam,local,12348,"http://www.cs.tau.ac.il/workshop/modas/webdam3.png");
fact picture@local(me,Jules,12349,"http://www.cs.mcgill.ca/~jtesta/images/profile.png");
fact picture@local(me,Julia,12350,"http://www.cs.columbia.edu/~jds1/pic_7.jpg");
fact picture@local(me,Julia,12351,"http://www.cs.tau.ac.il/workshop/modas/julia.png");

#Custom content
collection ext persistent person_example@local(_id*,name*);
collection ext persistent friend_example@local(_id1*,_id2*);

fact person_example@local(12345,oscar);
fact person_example@local(12346,hugo);
fact person_example@local(12347,kendrick);
fact friend_example@local(12345,12346);
fact friend_example@local(12346,12347);

fact location@local(12345,"New York");
fact location@local(12346,"New York");
fact location@local(12347,"New York");
fact location@local(12348,"Paris, France");
fact location@local(12349,"McGill University");
fact location@local(12350,"Columbia");
fact location@local(12351,"Tau workshop");

fact rating@local(12345,5);
fact rating@local(12349,5);

fact contact@local(Jules, localhost:4100, false, "jules.testard@mail.mcgill.ca", "Jules Testard");
fact contact@local(Julia, localhost:4100, false, "stoyanovich@drexel.edu", "jstoy");

rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
rule person_example@local($id,$name) :- friend_example@local($id,$name);
end