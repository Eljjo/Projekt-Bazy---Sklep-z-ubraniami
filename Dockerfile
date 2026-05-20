FROM postgres:18

RUN apt-get update && \
    apt-get install -y repmgr openssh-server tini && \
    apt-get clean

RUN usermod -d /home/postgres postgres && \
    mkdir -p /home/postgres && \
    chown -R postgres:postgres /home/postgres

RUN mkdir -p /var/run/sshd


RUN echo "postgres:haslo" | chpasswd

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["postgres"]
