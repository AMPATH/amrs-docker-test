FROM tomcat:8-jre8

ENV OPENMRS_HOME /root/.OpenMRS
ENV OPENMRS_MODULES ${OPENMRS_HOME}/modules
# ENV OPENMRS_PLATFORM_URL="https://nofile.io/f/TvXKVtdVjOX/openmrs.war"
# ENV OPENMRS_REST_URL="https://modules.openmrs.org/modulus/api/releases/1616/download/webservices.rest-2.20.0.omod"

ENV DB_NAME="openmrs"
ENV OPENMRS_DB_USER="root"
ENV OPENMRS_DB_PASS="devpassword"
ENV OPENMRS_MYSQL_HOST="localhost"
ENV OPENMRS_MYSQL_PORT="3306"

# Refresh repositories and add mysql-client and libxml2-utils (for xmllint)
# Download and Deploy OpenMRS
# Download and copy reference application modules (if defined)
# Unzip modules and copy to module/ref folder 
# Create database and setup openmrs db user
COPY openmrs.war /root/temp/
COPY ./data/demo.sql /root/temp/
RUN mkdir -p ${OPENMRS_HOME}
RUN apt-get update && apt-get install -y mysql-client libxml2-utils \
    && mkdir -p /root/temp/modules
RUN apt-get install -y software-properties-common && add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe' \
    && apt-get update &&   DEBIAN_FRONTEND=noninteractive apt install -y --allow-unauthenticated mysql-server-5.6  pwgen supervisor && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cp /usr/sbin/mysqld /usr/bin/mysqld
# Add image configuration and scripts
ADD start-tomcat.sh /start-tomcat.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD supervisord-tomcat.conf /etc/supervisor/conf.d/supervisord-tomcat.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD modules /root/temp/modules/
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD mysql-setup.sh /mysql-setup.sh
RUN chmod 755 /*.sh
#Copy OpenMRS properties file
COPY openmrs-runtime.properties /root/temp/
EXPOSE 8080

# Setup openmrs, optionally load demo data, and start tomcat
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ENTRYPOINT ["/run.sh"]
