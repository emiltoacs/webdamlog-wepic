peer sigmod_peer = localhost:4100;
collection ext persistent picture@local(title*, owner*, _id*, url*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact picture@local(sigmod,local,12347,"http://www.seeklogo.com/images/A/Acm_Sigmod-logo-F12330F5BD-seeklogo.com.gif");
fact picture@local(webdam,local,12348,"http://www.cs.tau.ac.il/workshop/modas/webdam3.png");
fact picturelocation@local(12347,"New York City");
fact picturelocation@local(12348,"INRIA, France");
fact contact@local(sigmod_peer,localhost,4100,false,"sigmod_peer@inria.fr");
rule contact@local($username, $ip, $port, $online, $email):-contact@sigmod_peer($username, $ip, $port, $online, $email);
rule contact@sigmod_peer($username,$ip,$port,$online,$email):-contact@local($username,$ip,$port,$online,$email);
