FROM centos:8

EXPOSE 2224 
EXPOSE 80

# Install nginx
RUN yum install epel-release -y
RUN yum install -y nginx

# Install Corosync and pacemaker
RUN sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/*-HighAvailability.repo
RUN yum update -y
RUN dnf install --assumeyes pacemaker corosync pcs which passwd
#RUN corosync-keygen #it can come in handy if there are problem with authentication

# Change password for hacluster user
RUN (echo 'S!n;_8M^M?rDRyKD'; echo 'S!n;_8M^M?rDRyKD') | passwd hacluster

RUN systemctl enable pcsd
RUN systemctl enable corosync
RUN systemctl enable pacemaker

# Script to execute after the systemd init to configure the cluster
WORKDIR /home
COPY ./run.sh ./
RUN chmod +x /home/run.sh

#Custom script as SystemD service
COPY ./shellscript.sh ./
RUN chmod +x shellscript.sh

# SystemD service wrapper for the custom script 
COPY ./shellscript.service  /lib/systemd/system/.

CMD ["/usr/sbin/init"]
