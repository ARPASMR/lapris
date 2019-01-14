FROM arpasmr/r-base
RUN apt-get update
RUN apt-get install -y s3cmd
RUN R -e "install.packages('sp',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('grid',repos='http://cran.us.r-project.org')"
RUN R -e "install.packages('gridExtra',repos='http://cran.us.r-project.org')"
WORKDIR /usr/src/myapp
COPY *.R ./
COPY *.sh ./
COPY info/* info/
RUN mkdir dati
CMD [".launch.sh","7200"]
