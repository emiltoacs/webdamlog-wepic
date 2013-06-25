collection ext persistent picture@local(title*, owner*, _id*, url*); #image data fields not added
collection ext persistent picturelocation@local(_id*, location*);
collection ext persistent rating@local(_id*, rating*, owner*);
collection ext persistent comment@local(_id*,author*,text*,date*);
collection ext persistent contact@local(username*, ip*, port*, online*, email*);
collection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);
fact contact@local(fakebootstrappeername, "127.0.0.1", 10000, false, none, none);

#end
