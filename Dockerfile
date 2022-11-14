FROM mambaorg/micromamba:1.0.0

COPY --chown=$MAMBA_USER:$MAMBA_USER env.yml /tmp/env.yml
COPY --chown=$MAMBA_USER:$MAMBA_USER pyproject.toml README.md src /tmp/cat12_app/

# the regular run_spm12.sh overrides all values for LD_LIBRARY_PATH, meaning that objects
# in the conda environment will not be found. the provided one will overried that, enables files
# like libncursesw.so.6 to be found 
COPY --chown=$MAMBA_USER:$MAMBA_USER src/cat12_app/data/run_spm12.sh /tmp/run_spm12.sh

ENV MAMBA_DOCKERFILE_ACTIVATE=1 
RUN micromamba install --quiet --name base --yes --file /tmp/env.yml \
    && pip install /tmp/cat12_app/ \
    && micromamba clean --all --yes \
    && rm -rf ~/.cache/pip/* \
    && rm -r /tmp/cat12_app

ENV LD_LIBRARY_PATH=/opt/conda/lib

ENV MATLAB_VERSION=R2017b
ENV MCR_VERSION=v93
ENV MCRROOT=/opt/mcr/${MCR_VERSION}
ENV MCR_INHIBIT_CTF_LOCK=1
ENV CAT_VERSION=12.8.1
ENV CAT_REVISION=r2042
ENV CAT_FULLVERSION=CAT${CAT_VERSION}_${CAT_REVISION}
ENV SPMROOT=/opt/${CAT_FULLVERSION}_${MATLAB_VERSION}_MCR_Linux

USER root

# RUN apt-get update \
#     && apt-get -y install libxext6 libxt6 \
#     && apt-get clean \
#     && apt-get autoremove \
#     && rm -rf /var/lib/apt/lists/* /var/tmp/*

RUN mkdir /tmp/mcr_install \
    && wget -q -P /tmp/mcr_install https://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_${MATLAB_VERSION}_glnxa64_installer.zip \
    && unzip -q /tmp/mcr_install/MCR_${MATLAB_VERSION}_glnxa64_installer.zip -d /tmp/mcr_install \
    && rm /tmp/mcr_install/*zip \
    && /tmp/mcr_install/install -destinationFolder ${MCRROOT} -agreeToLicense yes -mode silent \
    && rm -r /tmp/mcr_install /tmp/mathworks*  \
    && wget -q -P /tmp http://www.neuro.uni-jena.de/cat12/${CAT_FULLVERSION}_${MATLAB_VERSION}_MCR_Linux.zip \
    && unzip -q /tmp/${CAT_FULLVERSION}_${MATLAB_VERSION}_MCR_Linux.zip -d /opt \
    && rm /tmp/${CAT_FULLVERSION}_${MATLAB_VERSION}_MCR_Linux.zip \
    && mv /tmp/run_spm12.sh ${SPMROOT}/run_spm12.sh \
    && chmod a+x ${SPMROOT}/run_spm12.sh \
    && ${SPMROOT}/run_spm12.sh ${MCRROOT} --version \
    && chmod -R a+x ${SPMROOT} \
    && cp -l ${SPMROOT}/standalone/cat_standalone.sh /usr/local/bin/ 

USER $MAMBA_USER