ARG BASE_IMAGE=debian:latest
FROM $BASE_IMAGE
ARG EXTRA_INSTALLS=''
COPY InitEnv.sh /tmp
COPY *.deb /opt/
RUN chmod u+x /tmp/InitEnv.sh && /tmp/InitEnv.sh

CMD ["/bin/bash"]
