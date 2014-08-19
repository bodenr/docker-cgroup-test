FROM centos

RUN yum -y install gcc
ADD ./mem_munch.c /mem_munch.c
RUN gcc /mem_munch.c -o /mem_munch

CMD ["/mem_munch"]
