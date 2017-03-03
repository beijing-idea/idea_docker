# extend from centos:6
FROM centos:6

MAINTAINER Timothy Ren

# install subversion, mod_dav_svn, httpd, openssh-server
RUN yum -y install subversion mod_dav_svn httpd openssh-server

# create ssh service dirctory
RUN mkdir -p /var/run/sshd && mkdir -p /root/.ssh

# update ssh config to rsa authentication
RUN sed -ri 's/#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config
RUN sed -ri 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# config rsa user
COPY authorized_keys /root/.ssh/authorized_keys

# create svn repository, update repository owner
RUN mkdir /var/www/svn && cd /var/www/svn && svnadmin create repo1 && chown -R apache:apache repo1

# create auth and passwd
RUN cp /var/www/svn/repo1/conf/authz /var/www/svn/authz && cd /var/www/svn && touch passwd

# svn access apache
COPY subversion_add /var/tmp
RUN cat /var/tmp/subversion_add >> /etc/httpd/conf.d/subversion.conf

# run script
COPY run.sh /run.sh
RUN chmod 755 /run.sh

# configure the container to run apache, mapping container port 80 to that host port
EXPOSE 22 80
CMD ["/run.sh"]
