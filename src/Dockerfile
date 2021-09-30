FROM docker.io/condaforge/mambaforge-pypy3:4.10.3-6

# Set args
ARG CONDA_GROUP_NAME="cwl_ica_group"
ARG CONDA_GROUP_ID=1000
ARG CONDA_USER_NAME="cwl_ica_user"
ARG CONDA_USER_ID=1000
ARG CONDA_ENV_NAME="cwl-ica"

# Copy over src/ to . for user
COPY . "/cwl-ica-src-temp/"

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo Updating Apt 1>&2 && \
    apt-get update -y -q && \
    echo Installing jq, nodejs, rsync, graphviz and parallel 1>&2 && \
    apt-get install -y -q \
      jq \
      nodejs \
      rsync \
      graphviz \
      parallel && \
    echo Cleaning up after apt installations 1>&2 && \
    apt-get clean -y && \
    echo Installing yq 1>&2 && \
    wget --quiet \
        --output-document /usr/bin/yq \
        https://github.com/mikefarah/yq/releases/download/v4.11.2/yq_linux_amd64 && \
    chmod +x /usr/bin/yq && \
    echo Updating mamba 1>&2 && \
    mamba update --yes \
      --quiet \
      --name base \
      --channel defaults \
      mamba && \
    echo Adding user groups 1>&2 && \
    addgroup \
      --gid "${CONDA_GROUP_ID}" \
      "${CONDA_GROUP_NAME}" && \
    adduser \
      --disabled-password \
      --gid "${CONDA_GROUP_ID}" \
      --uid "${CONDA_USER_ID}" "${CONDA_USER_NAME}" && \
    cp -r "/cwl-ica-src-temp/." "/home/${CONDA_USER_NAME}/cwl-ica-src/" && \
    chown -R "${CONDA_USER_ID}:${CONDA_GROUP_ID}" "/home/${CONDA_USER_NAME}/cwl-ica-src/" && \
    rm -rf  "/cwl-ica-src-temp/"

# Switch to conda user
USER "${CONDA_USER_NAME}"
ENV USER="${CONDA_USER_NAME}"

# Add conda command
RUN echo "Adding in package and env paths to conda arc" 1>&2 && \
    echo 'pkgs_dirs' >> "/home/${CONDA_USER_NAME}/.condarc" && \
    echo '  - $HOME/.conda/pkgs' >> "/home/${CONDA_USER_NAME}/.condarc" && \
    echo 'envs_dirs' >> "/home/${CONDA_USER_NAME}/.condarc" && \
    echo '  - $HOME/.conda/envs' >> "/home/${CONDA_USER_NAME}/.condarc" && \
    echo "Installing into a conda env" 1>&2 && \
    (cd "/home/${CONDA_USER_NAME}" && bash "cwl-ica-src/install.sh" -y )

# Set environment variables for user
ENV CONDA_PREFIX="/home/${CONDA_USER_NAME}/.conda/envs/${CONDA_ENV_NAME}"
ENV CONDA_DEFAULT_ENV="${CONDA_ENV_NAME}"
ENV PATH="/home/${CONDA_USER_NAME}/.conda/envs/${CONDA_ENV_NAME}/bin:${PATH}"

CMD "cwl-ica"