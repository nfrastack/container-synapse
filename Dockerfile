ARG DISTRO=alpine
ARG DISTRO_VARIANT=3.21-7.10.31

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG SYNAPSE_VERSION
ARG PROVIDDER_LDAP_VERSION
ARG PROVIDER_REST_VERSION
ARG PROVIDER_S3_VERSION
ARG PROVIDER_SHARED_SECRET_VERSION

ENV SYNAPSE_VERSION=${SYNAPSE_VERSION:-"v1.137.0"} \
    PROVIDER_LDAP_VERSION=${PROVIDER_LDAP_VERSION:-"v0.3.0"} \
    PROVIDER_REST_VERSION=${PROVIDER_REST_VERSION:-"v0.1.4"} \
    PROVIDER_S3_VERSION=${PROVIDER_S3_VERSION:-"v1.4.0"} \
    PROVIDER_SHARED_SECRET_VERSION=${PROVIDER_SHARED_SECRET_VERSION:-"2.0.2"} \
    SYNAPSE_REPO_URL=https://github.com/element-hq/synapse \
    PROVIDER_LDAP_REPO_URL=https://github.com/matrix-org/matrix-synapse-ldap3 \
    PROVIDER_REST_REPO_URL=https://github.com/ma1uta/matrix-synapse-rest-password-provider \
    PROVIDER_S3_REPO_URL=https://github.com/ma1uta/matrix-synapse-s3-storage-provider \
    PROVIDER_SHARED_SECRET_REPO_URL=https://github.com/devture/matrix-synapse-shared-secret-auth \
    IMAGE_NAME="tiredofit/synapse" \
    IMAGE_REPO_URL="https://github.com/tiredofit/synapse/"

RUN source assets/functions/00-container && \
    set -x && \
    addgroup -S -g 8008 synapse && \
    adduser -D -S -s /sbin/nologin \
            -h /dev/null \
            -G synapse \
            -g "synapse" \
            -u 8008 synapse \
            && \
    \
    package update && \
    package upgrade && \
    package install .synapse-build-deps \
                    g++ \
#                    icu-dev \
                    py3-gpep517 \
                    py3-installer \
                    py3-poetry-core \
                    py3-pip \
                    py3-setuptools-rust \
                    py3-wheel \
                    python3-dev \
                    libpq-dev \
                    && \
    \
    package install .synapse-run-deps \
#                    icu \
                    inotify-tools \
                    libpq \
                    postgresql16-client \
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
                    && \
    \
#    pip install --upgrade --force --break-system-packages "pyicu" && \
    clone_git_repo "${SYNAPSE_REPO_URL}" "${SYNAPSE_VERSION}" && \
    gpep517 build-wheel \
             		--wheel-dir dist \
                        --output-fd 1 \
                        && \
    pip install --break-system-packages --upgrade dist/*.whl && \
    mkdir -p \
            /assets/synapse \
            /var/run/synapse \
            && \
    cp -R build/lib*/synapse/res/* /assets/synapse && \
    \
    chown -R synapse:synapse \
            /assets/synapse \
            /var/run/synapse \
            && \
    \
    clone_git_repo "${PROVIDER_LDAP_REPO_URL}" "${PROVIDER_LDAP_VERSION}" && \
    gpep517 build-wheel \
               		--wheel-dir dist \
                        --output-fd 1 \
                        && \
    pip install --break-system-packages --upgrade dist/*.whl && \
    \
    clone_git_repo "${PROVIDER_REST_REPO_URL}" "${PROVIDER_REST_VERSION}" && \
    cp rest_auth_provider.py /usr/lib/python*/site-packages && \
    \
    clone_git_repo "${PROVIDER_S3_REPO_URL}" "${PROVIDER_S3_VERSION}" && \
    gpep517 build-wheel \
               		--wheel-dir dist \
                        --output-fd 1 \
                        && \
    pip install --break-system-packages --upgrade dist/*.whl && \
    \
    clone_git_repo "${PROVIDER_SHARED_SECRET_REPO_URL}" "${PROVIDER_SHARED_SECRET_VERSION}" && \
    cp -R shared_secret_authenticator.py /usr/lib/python*/ && \
    \
    package remove .synapse-build-deps && \
    package cleanup && \
    \
    rm -rf /root/.cargo \
                /.cache \
                /usr/src/*

EXPOSE 8008

COPY install /
