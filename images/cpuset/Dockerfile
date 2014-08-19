FROM centos

RUN yum -y install gcc
ADD ./execp.c /execp.c
ADD ./execp.sh /execp.sh
RUN gcc /execp.c -o /execp
RUN chmod +x /execp.sh

CMD ["/execp.sh"]
