FROM centos:7

EXPOSE 2224 
EXPOSE 80

# Install nginx
RUN yum install epel-release -y
RUN yum install -y nginx


# Install Corosync and pacemaker
RUN yum install -y corosync pacemaker pcs haveged which
RUN corosync-keygen

# Change password for hacluster user
RUN (echo 'somepassword'; echo 'somepassword') | passwd hacluster

RUN systemctl enable pcsd
RUN systemctl enable corosync
RUN systemctl enable pacemaker

# Run script to execute after the systemd init
WORKDIR /home
COPY ./run.sh ./
RUN chmod +x /home/run.sh

CMD ["/usr/sbin/init"]
