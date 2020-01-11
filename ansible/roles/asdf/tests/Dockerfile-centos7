FROM centos:7

RUN yum -y install epel-release && \
    yum -y install sudo python python-devel python-pip gcc make \
     initscripts libffi-devel openssl-devel && \
    pip install -q cffi && \
    pip install -q ansible==2.5.1

WORKDIR /tmp/ansible-role-asdf
COPY  .  /tmp/ansible-role-asdf

RUN useradd -m vagrant
RUN echo localhost > inventory

RUN ansible-playbook -i inventory -c local tests/playbook.yml

RUN sudo -iu vagrant bash -lc 'asdf --version'
RUN sudo -iu vagrant bash -lc 'elixir --version'
