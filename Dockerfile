FROM arpasmr/r-base as intermediate
RUN apt-get update --fix-missing
RUN apt-get install -y s3cmd
RUN apt-get install -y python3
RUN R -e "install.packages('sp',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('grid',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('gridExtra',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('png',repos='http://cran.us.r-project.org')"
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
RUN mkdir templates
COPY templates/* templates/
RUN mkdir static
RUN mkdir static/js
COPY static/*.txt static/
COPY static/js/* static/js/
EXPOSE 8891/tcp
#CMD [".launch.sh","7200"]
