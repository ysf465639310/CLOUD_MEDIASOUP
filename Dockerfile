FROM node:14.0.0 AS stage-one

# Install DEB dependencies and others.
RUN \
	set -x \
	&& apt-get update \
	&& apt-get install -y net-tools build-essential valgrind

WORKDIR /mediasoup-demon


COPY * .

RUN cd  service

RUN npm install

RUN cd  ../webapp

RUN npm install


#CMD ["node", "/service/server.js"]

CMD ["bash start.sh"]
