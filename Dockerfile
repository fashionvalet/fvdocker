# ------------------------------------------------------------------------------
# Docker provisioning script for the docker-laravel web server stack
#
# 	e.g. docker build -t mtmacdonald/docker-laravel:version .
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Start with a base image
# ------------------------------------------------------------------------------

FROM mtmacdonald/docker-base:1.1.2

MAINTAINER Low Kian Seong <low@fashionvalet.com>

# Use Supervisor to run and manage all other services
# CMD ["supervisord", "-c", "/etc/supervisord.conf"]

# ------------------------------------------------------------------------------
# Provision the server
# ------------------------------------------------------------------------------

RUN mkdir /provision
ADD provision /provision
RUN /provision/provision.sh

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------

RUN echo 'root:abc123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# ------------------------------------------------------------------------------
# Expose Ports
# ------------------------------------------------------------------------------

EXPOSE 22 80

# ------------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------------

ENTRYPOINT service ssh start && /bin/bash
CMD ["/usr/sbin/sshd", "-D"]

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*