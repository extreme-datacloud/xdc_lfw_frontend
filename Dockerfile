#Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Ubuntu 16.04 (xenial) from 2017-07-23
# https://github.com/docker-library/official-images/commit/0ea9b38b835ffb656c497783321632ec7f87b60c
FROM jupyter/base-notebook:latest

MAINTAINER Fernando Aguilar <aguilarf@ifca.unican.es>

USER root
RUN apt-get update && \
    apt-get install git gnupg2 gcc libmysqlclient-dev wget apt-utils gdal-bin python3-gdal -y
# Install pymysql
RUN ls
RUN git clone https://github.com/extreme-datacloud/xdc_lfw_data.git

ENV WQ_REGION CdP
ENV WQ_START_DATE 01-01-2018
ENV WQ_END_DATE 18-01-2018
ENV WQ_ACTION cloud_coverage
ENV ONEDATA_TOKEN 'H4rGIxCMYsJSHQg1v6BpLGAwnDL01EE6AFAs1BCg'
ENV ONEDATA_URL 'https://vm027.pub.cloud.ifca.es'
ENV ONEDATA_API '/api/v3/oneprovider/'
ENV ONEDATA_SPACE Cyberhab
ENV ONEDATA_ZONE 'https://onezone.cloud.cnaf.infn.it'
ENV DOWNLOAD_FOLDER datasets
ENV ONECLIENT_PROVIDER_HOSTNAME 'vm027.pub.cloud.ifca.es'

#Create config file
RUN rm ./xdc_lfw_data/wq_modules/config.py
RUN exec 3<> ./xdc_lfw_data/wq_modules/config.py && \
    echo "#imports apis" >&3 && \
    echo "import os" >&3 && \
    echo "" >&3 && \
    echo "#onedata mode" >&3 && \
    echo "onedata_mode = 1" >&3 && \
    echo "if onedata_mode == 1:" >&3 && \
    echo "" >&3 && \
    echo "    #onedata path and info" >&3 && \
    echo "    onedata_token = \"$ONEDATA_TOKEN\"" >&3 && \
    echo "    onedata_url = \"$ONEDATA_URL\"" >&3 && \
    echo "    onedata_api = \"$ONEDATA_API\"" >&3 && \
    echo "    onedata_user = \"user\"" >&3 && \
    echo "    onedata_space = \"$ONEDATA_SPACE\"" >&3 && \
    echo "" >&3 && \
    echo "    #onedata path" >&3 && \
    echo "    datasets_path = \"/home/jovyan/datasets/$ONEDATA_SPACE\"" >&3 && \
    echo "" >&3 && \
    echo "#local path and info" >&3 && \
    echo "local_path = \"/home/jovyan/lfw_datasets\"" >&3 && \
    echo "" >&3 && \
    echo "#AEMET credentials" >&3 && \
    echo "METEO_API_TOKEN='eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ2aWxsYXJyakB1bmljYW4uZXMiLCJqdGkiOiJkZDc5ZjVmNy1hODQwLTRiYWQtYmMzZi1jNjI3Y2ZkYmUxNmYiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTUyMDg0NzgyOSwidXNlcklkIjoiZGQ3OWY1ZjctYTg0MC00YmFkLWJjM2YtYzYyN2NmZGJlMTZmIiwicm9sZSI6IiJ9.LMl_cKCtYi3RPwLwO7fJYZMes-bdMVR91lRFZbUSv84'" >&3 && \
    echo "" >&3 && \
    echo "METEO_API_URL='opendata.aemet.es'" >&3 && \
    echo "" >&3 && \
    echo "#Sentinel credentials" >&3 && \
    echo "sentinel_pass = {'username':\"lifewatch\", 'password':\"xta\"}" >&3 && \
    echo "" >&3 && \
    echo "#Landsat credentials" >&3 && \
    echo "landsat_pass = {'username':\"lifewatch\", 'password':\"xdda8\"}" >&3 && \
    echo "" >&3 && \
    echo "#available regions" >&3 && \
    echo "regions = {'CdP': {\"id\": 210788, \"coordinates\": {\"W\":-2.830, \"S\":41.820, \"E\":-2.690, \"N\":41.910}}, 'Cogotas': {\"id\": 214571, \"coordinates\": {\"W\":-4.728, \"S\":40.657, \"E\":-4.672, \"N\":40.731}}, 'Sanabria': {\"id\": 211645, \"coordinates\": {\"W\":-6.739, \"S\":42.107, \"E\":-6.689, \"N\":42.136}}, 'ElVal': {\"id\": 254845, \"coordinates\": {\"W\":-1.841, \"S\":41.861, \"E\":-1.779, \"N\":41.892}}}"  >&3 && \
    echo "" >&3 && \
    echo "#available actions" >&3 && \
    echo "keywords = [\"cloud_mask\", \"cloud_coverage\", \"water_mask\", \"water_surface\", \"None\"]" >&3 && \
    exec 3>&-
#TODO earth engine api installation
RUN chown -R jovyan:users ./xdc_lfw_data
RUN cd ./xdc_lfw_data && \
    /opt/conda/bin/python setup.py install
RUN exec 3<> /etc/apt/sources.list.d/onedata.list && \
    echo "deb [arch=amd64] http://packages.onedata.org/apt/ubuntu/1902 xenial main" >&3 && \
    echo "deb-src [arch=amd64] http://packages.onedata.org/apt/ubuntu/1902 xenial main" >&3 && \
    exec 3>&-
RUN apt-get install curl -y
RUN curl http://packages.onedata.org/onedata.gpg.key | apt-key add -
RUN apt-get update && curl http://packages.onedata.org/onedata.gpg.key | apt-key add -
RUN apt-get install python3-setuptools libgdal-dev oneclient=19.02.1-1~xenial -y
RUN adduser jovyan sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo 'Frontend installing...'
RUN git clone https://github.com/extreme-datacloud/xdc_lfw_frontend
RUN wget -O /home/jovyan/satellites.ipynb https://raw.githubusercontent.com/IFCA/wq_sat-Dockerfile/master/xdc_sat.ipynb
RUN wget -O /home/jovyan/xdc_sat_nb.py https://raw.githubusercontent.com/IFCA/wq_sat-Dockerfile/master/xdc_sat_nb.py
RUN exec 3<> ./xdc_lfw_frontend/regions.json && \
    echo '{"CdP":{"coordinates":{"W":-2.83 ,"S":41.82,"E":-2.67,"N":41.90}}, "Ebro":{"coordinates":{"W": -4.132, "S": 42.968, "E": -3.824, "N": 43.06}}}' >&3 && \
    exec 3>&-
RUN chown -R jovyan:users ./xdc_lfw_frontend/*
RUN mv ./xdc_lfw_frontend/.HY_MODEL.yml /home/jovyan/
RUN mv ./xdc_lfw_frontend/.SAT_DATA.yml /home/jovyan/
RUN mv ./xdc_lfw_frontend/XDC_nb.py /home/jovyan/
RUN mv ./xdc_lfw_frontend/XDC.ipynb /home/jovyan/
RUN mv ./xdc_lfw_frontend/test.sh /home/jovyan/
RUN mv ./xdc_lfw_frontend/views /home/jovyan/
RUN /opt/conda/bin/pip install pandas matplotlib netCDF4 xmltodict ipywidgets ipyleaflet
RUN /opt/conda/bin/pip install GDAL==$(gdal-config --version | awk -F'[.]' '{print $1"."$2}') --global-option=build_ext --global-option="-I/usr/include/gdal"
RUN mkdir datasets
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN rm -rf work xdc_lfw_data netcdf-4.4.0 xdc_lfw_frontend
RUN chown -R jovyan:users ./test.sh
RUN chmod 777 test.sh
