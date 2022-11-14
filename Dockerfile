FROM opensuse/tumbleweed
LABEL maintainer="Searx Guy"
ENV container=docker

ENV pip_packages "ansible"

RUN zypper -q update && zypper clean

# Enable systemd.
RUN zypper -q install systemd systemd-default-settings systemd-default-settings-branding-openSUSE \
    systemd-presets-branding-openSUSE systemd-presets-common-SUSE && zypper clean && \
  (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;
  # rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install pip and other requirements.
RUN zypper -qn install \
    python310 \
    python310-pip \
    sudo \
    which \
    cloud-init \
  && zypper clean

# Install Ansible via Pip.
RUN pip3 install $pip_packages

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/usr/sbin/init"]
