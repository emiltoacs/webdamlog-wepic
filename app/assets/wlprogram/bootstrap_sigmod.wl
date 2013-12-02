<<<<<<< HEAD
collection ext persistent picture@local(title*, owner*, _id*, url*);
=======
collection ext persistent picture@local(title*, owner*, _id*, url*); #image data fields not added
>>>>>>> 904bed5eca740584b2042a2ba177440f46ddf979
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
<<<<<<< HEAD
fact picture@local(sigmod,local,12347,"http://www.sigmod.org/2013/images/sigmod-logo.png");
=======
fact contact@local(fakebootstrappeername, "127.0.0.1", 10000, false, none, none);

>>>>>>> 904bed5eca740584b2042a2ba177440f46ddf979
#end
