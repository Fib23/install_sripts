/etc/asterisk/sip.conf
/etc/asterisk/extensions.conf
ls -la /var/lib/asterisk/moh/
drwxr-xr-x 2 asterisk asterisk 4096 апр  2  2020 .
drwxr-xr-x 5 asterisk asterisk 4096 фев  9 16:24 ..
-rw-r--r-- 1 asterisk asterisk 1900 апр  2  2020 btk.ulaw

asterisk -r
file convert  /var/lib/asterisk/moh/btk.wav /var/lib/asterisk/moh/btk.ulaw
asterisk -h
asterisk -v

nano /etc/asterisk/musiconhold.conf 106

/etc/asterisk/musiconhold.conf
[default]
mode=files
directory=moh

chown -r asterisk:asterisk moh/


 nano /etc/asterisk/users.conf  197


 chown asterisk:asterisk records/
 cp /home/andrei/sounds.wav /var/lib/asterisk/moh/voicemail/voicemenu.wav





 sip show peers
Name/username             Host                                    Dyn Forcerport Comedia    ACL Port     Status      Description                      
1001                      (Unspecified)                            D  No         No             0        UNKNOWN                                      
1002/1002                 (Unspecified)                            D  Auto (No)  No             0        Unmonitored                                  
beltel                    10.40.0.41                                  Yes        Yes            5060     OK (5 ms)                                    
3 sip peers [Monitored: 1 online, 1 offline Unmonitored: 0 online, 1 offline]

core reload