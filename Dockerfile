FROM payara/server-full:5.184

ENV MYSQL_VERSION 8.0.16
#Payara Pool Properties
ENV poolName MySQLPool
ENV databaseName twatter
## Change to docker container name ##
ENV serverName twatter_db
ENV port 3306
ENV password root
ENV user root
#JDBC
ENV jdbcUrl jdbc/twatter
#Payara
ENV asadminPath appserver/bin
ENV glassfishPath appserver/glassfish
ENV DOMAIN_NAME=production
ENV pwdPath passwordFile
ENV runAsAdmin ${asadminPath}/asadmin --user admin --passwordfile ${pwdPath}
ENV mysqlClassPath com.mysql.cj.jdbc.MysqlDataSource
ENV resourceType javax.sql.DataSource
#MYSQL
ENV connectorName="mysql-connector-java-${MYSQL_VERSION}.jar"

WORKDIR /opt/payara
COPY lib/ /opt/payara

RUN echo $(ls) \
  && cp ${connectorName} ${glassfishPath}/lib \
  && mv ${connectorName} ${glassfishPath}/domains/${DOMAIN_NAME}/lib \
  && ${runAsAdmin} start-domain ${DOMAIN_NAME} \
  && ${runAsAdmin} create-jdbc-connection-pool --datasourceclassname ${mysqlClassPath} --restype ${resourceType} --property port=${port}:password=${password}:user=${user}:serverName=${serverName}:databaseName=${databaseName}:useSSL=false:nullNamePatternMatchesAll=false:nullCatalogMeansCurrent=true:useInformationSchema=true:serverTimezone=CET:useUnicode=true:zeroDateTimeBehavior=CONVERT_TO_NULL:characterEncoding=UTF8:allowPublicKeyRetrieval=true:createDatabaseIfNotExist=true ${poolName} \
  && ${runAsAdmin} create-jdbc-resource --connectionpoolid ${poolName} ${jdbcUrl} \
  && ${asadminPath}/asadmin stop-domain ${DOMAIN_NAME} \
  && echo $(ls)
