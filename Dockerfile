FROM arpasmr/r-base
RUN apt-get update
ENV http_proxy=http://meteo:%meteo2010@proxy2.arpa.local:8080
ENV https_proxy=https://meteo:%meteo2010@proxy2.arpa.local:8080
#RUN apt-get install -y s3cmd
RUN apt-get install -y python3
RUN R -e "install.packages('sp',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('grid',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('gridExtra',repos='http://cran.us.r-project.org')"
RUN pip install Minio
WORKDIR /usr/src/myapp
COPY *.R ./
COPY *.py ./
COPY *.sh ./
COPY info/* info/
RUN mkdir dati
#CMD [".launch.sh","7200"]
