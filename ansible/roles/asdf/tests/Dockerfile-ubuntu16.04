FROM ubuntu:16.04

RUN apt-get update -qq && \
    apt-get install -qq sudo python-apt python-pycurl python-pip python-dev \
                        libffi-dev libssl-dev && \
    pip install -U setuptools && \
    pip install -q ansible==2.5.1

WORKDIR /tmp/ansible-role-asdf
COPY  .  /tmp/ansible-role-asdf

RUN useradd -m vagrant
RUN echo localhost > inventory

RUN ansible-playbook -i inventory -c local tests/playbook.yml

RUN sudo -iu vagrant bash -lc 'asdf --version'
RUN sudo -iu vagrant bash -lc 'elixir --version'
