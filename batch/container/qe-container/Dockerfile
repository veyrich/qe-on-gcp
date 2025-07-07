FROM rockylinux:8

RUN dnf install -y epel-release; /usr/bin/crb  enable; dnf install -y quantum-espresso

ENTRYPOINT ["/tmp/data/run-Cu1.sh"]