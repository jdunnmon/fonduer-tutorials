FROM jupyter/minimal-notebook
LABEL maintainer="Hiromu Hota <hiromu.hota@hal.hitachi.com>"
USER root

RUN apt-get install gnupg
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'
RUN apt update
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libxslt-dev \
    python-matplotlib \
    poppler-utils \
    postgresql-11 \
    libmagickwand-dev \
    ghostscript \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN rm /etc/ImageMagick-6/policy.xml

USER $NB_UID

RUN pip install \
    "fonduer>=0.5.0" \
    matplotlib

RUN python -m spacy download en
RUN conda install -y -c conda-forge ipywidgets

# Copy notebooks and download data
COPY --chown=jovyan:users hardware hardware
RUN cd hardware && /bin/bash download_data.sh
COPY --chown=jovyan:users hardware_image hardware_image
RUN cd hardware_image && /bin/bash download_data.sh
COPY --chown=jovyan:users intro intro
RUN cd intro && /bin/bash download_data.sh
COPY --chown=jovyan:users wiki wiki
RUN cd wiki && /bin/bash download_data.sh

# Specify the hostname of postgres b/c it's not local
RUN sed -i -e 's/localhost/postgres/g' */*.ipynb
RUN sed -i -e 's/dropdb/dropdb -h postgres/g' */*.ipynb
RUN sed -i -e 's/createdb/createdb -h postgres/g' */*.ipynb
RUN sed -i -e 's/psql/psql -h postgres/g' */*.ipynb
