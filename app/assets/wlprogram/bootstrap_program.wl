peer sigmod_peer = localhost:4100;
collection ext persistent picture@local(title*, owner*, _id*, url*);
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*, author*, text*, date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact picture@local(webdam,local,12348,"http://webdam.inria.fr/wordpress/wp-content/uploads/2009/08/webdam_200.png");
fact picturelocation@local(12348,"INRIA, France");
fact contact@local(sigmod_peer,localhost,4100,false,"sigmod_peer@inria.fr");
rule contact@sigmod_peer($username,$ip,$port,$online,$email):-contact@local($username,$ip,$port,$online,$email);
rule contact@local($username, $ip, $port, $online, $email):-contact@sigmod_peer($username, $ip, $port, $online, $email);
#end