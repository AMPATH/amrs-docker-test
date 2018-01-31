#!/bin/bash

# Only load db and modules if this script is being loaded for the first time (ie, docker run)
if [ -d "/root/temp" ]; then
# ------------ Begin Load Database ------------
mysqld --initialize-insecure --user=mysql > /dev/null 2>&1
/create_mysql_admin_user.sh
echo "Using MySQL host: ${OPENMRS_MYSQL_HOST}"

echo "Using MySQL port: ${OPENMRS_MYSQL_PORT}"

 # Write openmrs-runtime.properties file with linked database settings
OPENMRS_CONNECTION_URL="connection.url=jdbc\:mysql\://$OPENMRS_MYSQL_HOST\:$OPENMRS_MYSQL_PORT/${DB_NAME}?autoReconnect\=true&sessionVariables\=default_storage_engine\=InnoDB&useUnicode\=true&characterEncoding\=UTF-8"
echo "${OPENMRS_CONNECTION_URL}" >> /root/temp/openmrs-runtime.properties
echo "connection.username=${OPENMRS_DB_USER}" >> /root/temp/openmrs-runtime.properties
echo "connection.password=${OPENMRS_DB_PASS}" >> /root/temp/openmrs-runtime.properties
mkdir -pv ${OPENMRS_HOME}/${OPENMRS_NAME}
cp /root/temp/openmrs-runtime.properties ${OPENMRS_HOME}/${OPENMRS_NAME}/${OPENMRS_NAME}-runtime.properties
cp /root/temp/openmrs.war  ${CATALINA_HOME}/webapps/${OPENMRS_NAME}.war
# Copy base/dependency modules to module folder
echo "Copying module dependencies and reference application modules..."
export OPENMRS_MODULES=${OPENMRS_HOME}/${OPENMRS_NAME}/modules
rm -rf OPENMRS_MODULES;
mkdir -pv $OPENMRS_MODULES
cp /root/temp/modules/*.omod $OPENMRS_MODULES
rm -rf ${OPENMRS_HOME}/${OPENMRS_NAME}/.openmrs-lib-cache/
echo "Modules copied."

# Cleanup temp files
rm -r /root/temp
fi

# Set custom memory options for tomcat
export JAVA_OPTS="-Dfile.encoding=UTF-8 -server -Xms256m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"

# Run tomcat
# catalina.sh run
supervisord -n