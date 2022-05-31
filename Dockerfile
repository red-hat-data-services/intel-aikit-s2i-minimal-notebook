# This image provides a Python 3.9 environment you can use to run your Python
# applications.

ARG IMAGE_NAME=registry.access.redhat.com/ubi8/s2i-core
ARG IMAGE_TAG=latest

FROM ${IMAGE_NAME}:${IMAGE_TAG}

USER root

EXPOSE 8080

# TODO(Spryor): ensure these are right, add Anaconda versions
ENV PYTHON_VERSION=3.9 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PIP_NO_CACHE_DIR=off \
    APP_ROOT=/opt/app-root \
    CONDA_ROOT=${APP_ROOT}/miniconda3 \
    PATH=${APP_ROOT}/miniconda3/bin:${PATH}

# Intel TensorFlow specific Envs
ENV KMP_AFFINITY='granularity=fine,verbose,compact,1,0' \
    KMP_BLOCKTIME=1 \
    KMP_SETTINGS=1

# RHEL7 base images automatically set these envvars to run scl_enable. RHEl8
# images, however, don't as most images don't need SCLs any more. But we want
# to run it even on RHEL8, because we set the virtualenv environment as part of
# that script
#ENV BASH_ENV=${APP_ROOT}/etc/scl_enable \
#    ENV=${APP_ROOT}/etc/scl_enable \
#    PROMPT_COMMAND=". ${APP_ROOT}/etc/scl_enable"

# Ensure we're enabling Anaconda by forcing the activation script in the shell
# ENV BASH_ENV="${CONDA_ROOT}/bin/activate ${CONDA_ENV}" \
#     ENV="${CONDA_ROOT}/bin/activate ${CONDA_ENV}" \
#     PROMPT_COMMAND=". ${CONDA_ROOT}/bin/activate ${CONDA_ENV}"

ENV SUMMARY="" \
    DESCRIPTION=""

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Anaconda Python 3.9" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python39,python-39,miniconda3" \
      com.redhat.component="python-39-container" \
      name="ubi8/miniconda3" \
      version="1" \
      usage="" \
      maintainer="Probably Anaconda"

RUN yum -y module enable httpd:2.4 && \
    INSTALL_PKGS="atlas-devel \
    enchant \
    gcc-gfortran \
    git \
    httpd \
    httpd-devel \
    libffi-devel \
    libtool-ltdl \
    mod_auth_gssapi \
    mod_ldap \
    mod_session \
    mod_ssl \
    nss_wrapper \
    tar \
    unzip \
    wget \
    zip" && \
    yum -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

# TODO(Spryor): What extra files exactly...?
# Copy extra files to the image.
# COPY ./root/ /

# - Create a Python virtual environment for use by any application to avoid
#   potential conflicts with Python packages preinstalled in the main Python
#   installation.
# - In order to drop the root user, we have to make some directories world
#   writable as OpenShift default security model is to run the container
#   under random UID.

ARG CONDA_VERSION=py39_4.10.3
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh > Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh && \
    chmod +x Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh && \
    ./Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -b -p ${CONDA_ROOT} && \
    rm ./Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh 

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src && \
    rm -rf /tmp/scripts && \
    mv /tmp/src/.s2i/bin /tmp/scripts

RUN /tmp/scripts/assemble

RUN conda config --set auto_activate_base false

RUN conda clean -y --all

USER 1001

# Clone Intel Model Zoo and Intel AI-Kit examples
# RUN mkdir ${APP_ROOT}/src/models && \
#     cd ${APP_ROOT}/src/models && \
#     curl -sSL --retry 5 https://github.com/IntelAI/models/tarball/HEAD | tar --strip-components=1 -xzf - && \
#     mkdir /tmp/intel-aikit-examples && \
#     cd /tmp/intel-aikit-examples && \
#     curl -sSL --retry 5 https://github.com/preethivenkatesh/oneAPI-samples/tarball/HEAD | tar --strip-components=1 -xzf - && \
#     mv AI-and-Analytics/RHODS-e2e ${APP_ROOT}/src/intel-aikit-examples && \
#     rm -rf /tmp/intel-aikit-examples

CMD [ "/opt/app-root/builder/run" ]
