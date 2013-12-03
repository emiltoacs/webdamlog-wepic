collection ext persistent picture@local(title*, owner*, _id*, url*);
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact picture@local(sigmod,local,12347,"http://www.sigmod.org/2013/images/sigmod-logo.png");
#end
