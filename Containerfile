# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Synapse" \
        org.opencontainers.image.description="Matrix Homeserver" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/synapse" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-synapse/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-synapse.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    SYNAPSE_VERSION="v1.140.0" \
    PROVIDDER_LDAP_VERSION="v0.3.0" \
    PROVIDER_SHARED_SECRET_VERSION="2.0.3" \
    SYNAPSE_REPO_URL="https://github.com/element-hq/synapse" \
    PROVIDER_LDAP_REPO_URL="https://github.com/matrix-org/matrix-synapse-ldap3" \
    PROVIDER_SHARED_SECRET_REPO_URL="https://github.com/devture/matrix-synapse-shared-secret-auth"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    IMAGE_NAME="nfrastack/synapse" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-synapse/"

RUN echo "" && \
    SYNAPSE_BUILD_DEPS_ALPINE=" \
                                    g++ \
                                    py3-gpep517 \
                                    py3-installer \
                                    py3-poetry-core \
                                    py3-pip \
                                    py3-setuptools-rust \
                                    py3-wheel \
                                    python3-dev \
                                    libpq-dev \
                                " \
                                && \
    \
    SYNAPSE_RUN_DEPS_ALPINE=" \
                                inotify-tools \
                                libpq \
                                postgresql-client \
                                python3 \
                                py3-asn1 \
                                py3-asn1-modules \
                                py3-attrs \
                                py3-authlib \
                                py3-boto3 \
                                py3-botocore \
                                py3-bcrypt \
                                py3-bleach \
                                py3-canonicaljson \
                                py3-daemonize \
                                py3-eliot \
                                py3-frozendict \
                                py3-humanize \
                                py3-idna \
                                py3-ijson \
                                py3-jinja2 \
                                py3-jsonschema \
                                py3-jwt \
                                py3-ldap3 \
                                py3-lxml \
                                py3-matrix-common \
                                py3-msgpack \
                                py3-netaddr \
                                py3-openssl \
                                py3-phonenumbers \
                                py3-pillow \
                                py3-prometheus-client \
                                py3-psycopg2 \
                                py3-pydantic \
                                py3-pymacaroons \
                                py3-pynacl \
                                py3-saml2 \
                                py3-service_identity \
                                py3-signedjson \
                                py3-sortedcontainers \
                                py3-treq \
                                py3-tqdm \
                                py3-twisted \
                                py3-txacme \
                                py3-txredisapi \
                                py3-typing-extensions \
                                py3-yaml \
                                sed \
                                sqlite \
                                yq-go \
                            " \
                            && \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user synapse 8008 synapse 8008 /dev/null && \
    package update && \
    package upgrade && \
    package install \
                        SYNAPSE_BUILD_DEPS \
                        SYNAPSE_RUN_DEPS \
                    && \
    \
    clone_git_repo "${SYNAPSE_REPO_URL}" "${SYNAPSE_VERSION}" && \
    gpep517 build-wheel \
             		    --wheel-dir dist \
                        --output-fd 1 \
                        && \
    pip install \
                --break-system-packages \
                --root-user-action ignore \
                --upgrade dist/*.whl && \
    mkdir -p \
            /container/data/synapse \
            /var/run/synapse \
            && \
    echo "${SYNAPSE_VERSION}" > /var/run/synapse/version && \
    cp -R build/lib*/synapse/res/* /container/data/synapse && \
    \
    chown -R synapse:synapse \
                                /container/data/synapse \
                                /var/run/synapse \
                                && \
    \
    container_build_log add "Synapse" "${SYNAPSE_VERSION}" "${SYNAPSE_REPO_URL}" && \
    clone_git_repo "${PROVIDER_LDAP_REPO_URL}" "${PROVIDER_LDAP_VERSION}" && \
    gpep517 build-wheel \
               		    --wheel-dir dist \
                        --output-fd 1 \
                        && \
    pip install --break-system-packages --upgrade dist/*.whl && \
    container_build_log add "Synapse LDAP Authentication Provider" "${PROVIDDER_LDAP_VERSION}" "${PROVIDER_LDAP_REPO_URL}" && \
    \
    clone_git_repo "${PROVIDER_SHARED_SECRET_REPO_URL}" "${PROVIDER_SHARED_SECRET_VERSION}" && \
    cp -R shared_secret_authenticator.py /usr/lib/python*/ && \
    container_build_log add "Synapse Shared Secret provider" "${PROVIDER_SHARED_SECRET_VERSION}" "${PROVIDER_SHARED_SECRET_REPO_URL}" && \
    \
    package remove \
                    SYNAPSE_BUILD_DEPS \
                    && \
    package cleanup

EXPOSE 8008

COPY rootfs /
