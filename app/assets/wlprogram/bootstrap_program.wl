peer sigmod_peer = juleshost:4100;
collection ext persistent picture@jules(title*, owner*, _id*, image_url*); #image data fields not added
collection ext persistent picturelocation@jules(_id*, location*);
collection ext persistent rating@jules(_id*, rating*, owner*);
collection ext persistent comment@jules(_id*,author*,text*,date*);
collection ext persistent contact@jules(username*, peerlocation*, online*, email*, facebook*);
collection ext persistent describedrule@jules(wdlrule*, description*);
fact picture@jules(sigmod,Jules,12345,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@jules(sigmod,Julia,12346,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@jules(sigmod,jules,12347,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@jules(webdam,jules,12348,"http://www.cs.tau.ac.il/workshop/modas/webdam3.png");
fact picture@jules(me,Jules,12349,"http://www.cs.mcgill.ca/~jtesta/images/profile.png");
fact picture@jules(me,Julia,12350,"http://www.cs.columbia.edu/~jds1/pic_7.jpg");
fact picture@jules(me,Julia,12351,"http://www.cs.tau.ac.il/workshop/modas/julia.png");
#Custom content
collection ext persistent person@jules(_id*,name*);
collection ext persistent friend@jules(_id1*,_id2*);
fact person@jules(12345,oscar);
fact person@jules(12346,hugo);
fact person@jules(12347,kendrick);
fact friend@jules(12345,12346);
fact friend@jules(12346,12347);

fact location@jules(12345,"New York");
fact location@jules(12346,"New York");
fact location@jules(12347,"New York");
fact location@jules(12348,"Paris, France");
fact location@jules(12349,"McGill University");
fact location@jules(12350,"Columbia");
fact location@jules(12351,"Tau workshop");

fact rating@jules(12345,5,Jules);
fact rating@jules(12349,5,Julia);

fact contact@jules(Jules, juleshost:4100, false, "jules.testard@mail.mcgill.ca", "Jules Testard");
fact contact@jules(Julia, juleshost:4100, false, "stoyanovich@drexel.edu", "jstoy");

rule contact@jules($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);
rule person@jules($id,$name) :- friend@jules($id,$name);
end