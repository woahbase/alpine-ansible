# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG MITOGEN_VERSION=0.3.12
#
ENV \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    MITOGEN_DIR=/opt/mitogen \
    MITOGEN_VERSION=${MITOGEN_VERSION}
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        black \
        ca-certificates \
        curl \
        libffi \
        openssh \
        openssl \
        py3-bcrypt \
        py3-certifi \
        py3-cffi \
        # py3-cryptography \
        # # for xml parsing e.g. for OpenSUSE Zypper packages
        py3-lxml \
        py3-markupsafe \
        py3-pynacl \
        py3-ruamel.yaml.clib \
        py3-six \
        py3-yaml \
    && apk add --update --virtual .build-dependencies \
        build-base \
        cython \
        # # new cryptography requires rust to build
        cargo \
        libffi-dev \
        linux-headers \
        openssl-dev \
        python3-dev \
    && pip3 install --no-cache-dir --break-system-packages --upgrade \
        pip \
        setuptools \
        wheel \
    && pip3 install --no-cache-dir --break-system-packages \
        # # needed packages
        # # enable for python3.6 support (dropped since ansible-core==2.17)
        # ansible-core==2.16.14 \
        ansible \
        ansible-lint \
        molecule \
#
        # # extra pip packages
        # ansible-cmdb \
        cryptography \
        requests \
        # # for json queries
        jmespath \
        # ssh transport optional
        paramiko \
        # # python default crypt module deprecated 2.13
        passlib \
        # for facts-cache (optional)
        redis \
#
        # for dns
        dnspython \
        # # docker packages
        docker \
        # # docker-compose now deprecated, install docker-cli[-compose] at runtime instead
        # docker-compose \
#
        # for expect
        pexpect \
        ptyprocess \

        # # hashicorp consul, vault, and nomad
        pyhcl \
        python-consul \
        hvac \
        python-nomad \
#
        # # for windows hosts (remote)
        pypsrp \
        pywinrm \
#
        # # pretty formatting
        # yamlfmt \
        # # python yamlfmt now deprecated
        # # TODO: try google's instead (or prettier??)
        # # fallback to yamlfix,
        yamlfix \
        # # optionals: add as needed at runtime via S6_PIP_PACKAGES or part of playbook
    && apk del --purge .build-dependencies \
#   # extra packages
    && apk add --no-cache --purge -uU \
        expect \
        git \
        make \
        rsync \
        sshpass \
        sudo \
#
        # # optionals: add at runtime via S6_NEEDED_PACKAGES or part of playbook
        # docker-cli \
        # docker-cli-compose \
#
    && mkdir -p \
        /etc/ansible \
        ${MITOGEN_DIR} \
    && curl -jSLN \
        -o /tmp/mitogen.tar.gz \
        https://files.pythonhosted.org/packages/source/m/mitogen/mitogen-${MITOGEN_VERSION}.tar.gz \
    && tar xzf /tmp/mitogen.tar.gz -C ${MITOGEN_DIR} --strip-components=1 \
#
    && echo 'localhost' > /etc/ansible/hosts \
    && echo "${S6_USER:-alpine} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
#
    && rm -rf /var/cache/apk/* /tmp/* /root/.cache /root/.cargo
#
# VOLUME /home/${S6_USER:-alpine}/ # bind mount on host
# WORKDIR /home/${S6_USER:-alpine}/
#
ENTRYPOINT ["/usershell"]
#
CMD ["ansible", "--version"]
