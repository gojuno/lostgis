FROM mdillon/postgis:9.6

RUN apt-get update; \
    apt-get install -y sudo make git postgresql-server-dev-9.6 \
    postgresql-plpython-9.6 pgtap

RUN apt-get install -y python-pip; \
    pip install pgxnclient
