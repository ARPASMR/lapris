FROM arpasmr/r-base as intermediate
RUN apt-get update
#ENV http_proxy=http://meteo:%meteo2010@proxy2.arpa.local:8080
#ENV https_proxy=https://meteo:%meteo2010@proxy2.arpa.local:8080
RUN apt-get install -y s3cmd
RUN apt-get install -y python3
RUN R -e "install.packages('sp',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('grid',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('gridExtra',repos='http://cran.us.r-project.org')"
RUN apt-get install -y python3-pip
RUN pip3 install minio
RUN pip3 install flask
FROM intermediate as final
WORKDIR /usr/src/myapp
COPY *.R ./
COPY *.py ./
COPY *.sh ./
COPY info/* info/
COPY config_minio.txt ./
RUN mkdir dati
RUN mkdir img
#CMD [".launch.sh","7200"]
