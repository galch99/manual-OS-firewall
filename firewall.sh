#/bin/sh
ACCEPT_IP=x.x.x.x 
ACCEPT_IP1=x.x.x.z
.....


LOCAL_IP=y.y.y.y
ACCETP_Port=ZZZ - жишээ нь ssh port (22)

#Бүх рүүлүүдийг усгана. Шинээр рүүл нэмхэд бэлдэхнээ.
/sbin/iptables -F
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -P OUTPUT ACCEPT

#Зөвшөөрсөн IP-наас ZZZ портыг зөвшөөрнө. Үүнийг хэд хэдэн удаа бичээд хэрэгтэй портоо нээнэ.
/sbin/iptables -A INPUT -p tcp -m iprange --src-range $ACCEPT_IP -d $LOCAL_IP --sport 513:65535 --dport $ZZZ -m state --state NEW,ESTABLISHED -j ACCEPT

#Мэдээж DNS хэрэгтэй болно.
/sbin/iptables -A OUTPUT -p udp -s $LOCAL_IP -d 8.8.8.8 --sport 513:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
/sbin/iptables -A OUTPUT -p tcp -s $LOCAL_IP -d 8.8.8.8 --sport 513:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
/sbin/iptables -A INPUT -p udp -s 8.8.8.8 -d $LOCAL_IP --sport 53 --dport 513:65535 -m state --state NEW,ESTABLISHED -j ACCEPT
/sbin/iptables -A INPUT -p tcp -s 8.8.8.8 -d $LOCAL_IP --sport 53 --dport 513:65535 -m state --state NEW,ESTABLISHED -j ACCEPT
#
#Өөрийн серверээс хаашаа ч 80, 443аар хандаж болохоор тохируулна.
/sbin/iptables -A OUTPUT -p tcp -s $LOCAL_IP -d 0/0 --sport 513:65535 --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
/sbin/iptables -A OUTPUT -p tcp -s $LOCAL_IP -d 0/0 --sport 513:65535 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT


#Гаднаас жишээ нь: 80, 443 портыг нээе
/sbin/iptables -A INPUT -p tcp -s 0/0 -d $LOCAL_IP --sport 443 --dport 513:65535 -m state --state NEW,ESTABLISHED -j ACCEPT
/sbin/iptables -A INPUT -p tcp -s 0/0 -d $LOCAL_IP --sport 80 --dport 513:65535 -m state --state NEW,ESTABLISHED -j ACCEPT

#Юмыг яаж мэдхэв гээд icmp нээх хэрэгтэй. унтарсаныг мэдэх хэрэгтэй
/sbin/iptables -A OUTPUT -p icmp --icmp-type 8 -s $LOCAL_IP -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -p icmp --icmp-type 0 -s 0/0  -d $LOCAL_IP -m state --state ESTABLISHED,RELATED -j ACCEPT


#Локалдаа сервис ажлуулахад хэрэглэнэ.
/sbin/iptables -A INPUT -s 127.0.0.1 -j ACCEPT
/sbin/iptables -A OUTPUT -s 127.0.0.1 -j ACCEPT
/sbin/iptables -A INPUT -s $LOCAL_IP -j ACCEPT
/sbin/iptables -A OUTPUT -s $LOCAL_IP -j ACCEPT
/sbin/iptables -A INPUT -s localhost -j ACCEPT
/sbin/iptables -A OUTPUT -s localhost -j ACCEPT

#За одоо бусдыг нь хаана
/sbin/iptables -A INPUT -j DROP
/sbin/iptables -A OUTPUT -j DROP
