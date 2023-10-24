################################################################################
# Dockerfile that builds runtime environment 
#   for AUTOMATIC1111/stable-diffusion-webui.
################################################################################

FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

LABEL maintainer="renz7"

WORKDIR /root

#COPY ./source.list /etc/apt/sources.list
ENV TZ=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN --mount=type=cache,target=/var/cache/apt \
    apt update -y \
    && apt install -yqq --no-install-recommends wget git python3.10-dev python3-venv python3-psutil python3-pip libgl1 libglib2.0-0 aria2

RUN pip3 install -U pip setuptools

# Install xFormers (will install PyTorch as well)
#RUN pip install -U torch xformers

# All remaining deps are described in txt
COPY ["requirements.txt","/root/"]
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install -r /root/requirements.txt

# Fix for libs (.so files)
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib64/python3.11/site-packages/torch/lib"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.11/site-packages/nvidia/cufft/lib"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.11/site-packages/nvidia/cuda_runtime/lib"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.11/site-packages/nvidia/cuda_cupti/lib"

# Create a low-privilege user.
RUN printf 'CREATE_MAIL_SPOOL=no' > /etc/default/useradd \
    && mkdir -p /home/runner /home/scripts \
    && groupadd runner \
    && useradd runner -g runner -d /home/runner \
    && chown runner:runner /home/runner /home/scripts

COPY --chown=runner:runner scripts/. /home/scripts/

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner
ENV CLI_ARGS=""
EXPOSE 7860
STOPSIGNAL SIGINT
CMD bash /home/scripts/entrypoint.sh
