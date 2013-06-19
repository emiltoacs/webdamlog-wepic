peer sigmod_peer = localhost:4100;
collection ext persistent picture@local(title*, owner*, _id*, image_url*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact picture@local(sigmod,local,12347,"http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif");
fact picture@local(webdam,local,12348,"http://www.cs.tau.ac.il/workshop/modas/webdam3.png");
fact picturelocation@local(12347,"Columbia");
fact picturelocation@local(12348,"Tau workshop");
fact contact@local(sigmod_peer,localhost,4100,false,"sigmod_peer@inria.fr");
rule contact@local($username, $ip, $port, $online, $email):-contact@sigmod_peer($username, $ip, $port, $online, $email);
end