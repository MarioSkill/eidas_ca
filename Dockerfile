				#############################################################
				# Dockerfile - eIDAS 	1.4.0			            #
				# 						      	    #
				#############################################################

FROM ubuntu:16.04
# Actualización de la lista de fuentes del repositorio de aplicaciones por defecto
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get install -y git && \
    apt-get install -y curl && \
    apt-cache search maven && \
    apt-get install -y maven && \
    apt-get clean
#Configuramos el entorno
RUN apt-get install -y zip unzip

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle/
ENV EIDAS_VERSION 1.4.0
ENV TOMCAT_VERSION 8.5.27
ENV WEB_SERVER_PATH /usr/local/src/tomcat

ENV EIDAS_PATH /usr/local/src/eidas
RUN mkdir $EIDAS_PATH

RUN wget https://ec.europa.eu/cefdigital/artifact/content/repositories/eid/eu/eIDAS-node/$EIDAS_VERSION/eIDAS-node-$EIDAS_VERSION.zip
RUN wget http://www-us.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN unzip eIDAS-node-$EIDAS_VERSION.zip -d eidas_src
RUN unzip ./eidas_src/EIDAS-Binaries-Tomcat-$EIDAS_VERSION.zip -d ./eidas_src/binaries
RUN unzip ./eidas_src/binaries/TOMCAT/config.zip -d ./eidas_src/binaries/config

RUN mv eidas_src/binaries/config $EIDAS_PATH/config

RUN tar -xzvf apache-tomcat-$TOMCAT_VERSION.tar.gz
RUN mv apache-tomcat-$TOMCAT_VERSION $WEB_SERVER_PATH

ENV EIDAS_CONFIG_REPOSITORY $EIDAS_PATH/config/tomcat/
ENV SPECIFIC_CONFIG_REPOSITORY $EIDAS_PATH/config/tomcat/specific/
ENV SP_CONFIG_REPOSITORY $EIDAS_PATH/config/tomcat/sp/
ENV IDP_CONFIG_REPOSITORY $EIDAS_PATH/config/tomcat/idp/

RUN mv eidas_src/binaries/TOMCAT/EidasNode.war $WEB_SERVER_PATH/webapps
RUN mv eidas_src/binaries/TOMCAT/SP.war $WEB_SERVER_PATH/webapps
RUN mv eidas_src/binaries/TOMCAT/IdP.war $WEB_SERVER_PATH/webapps
RUN rm apache-tomcat-$TOMCAT_VERSION.tar.gz
RUN rm eIDAS-node-$EIDAS_VERSION.zip

RUN echo '<?xml version="1.0" encoding="UTF-8"?> <tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0"> <role rolename="manager-gui"/> <user username="tomcat" password="tomcat" roles="tomcat, manager-gui"/> <user name="admin" password="admin" roles="rssbus_admin,admin-gui,manager-gui,manager-status,manager-script,manager-jmx" /> </tomcat-users>' > $WEB_SERVER_PATH/conf/tomcat-users.xml
RUN mkdir $WEB_SERVER_PATH/shared
RUN mkdir $WEB_SERVER_PATH/shared/lib
RUN cp /eidas_src/binaries/AdditionalFiles/endorsed/* /usr/local/src/tomcat/shared/lib

RUN echo 'package.access=sun.,org.apache.catalina.,org.apache.coyote.,org.apache.jasper.,org.apache.tomcat.' > $WEB_SERVER_PATH/conf/catalina.properties
RUN echo 'package.definition=sun.,java.,org.apache.catalina.,org.apache.coyote.,\
org.apache.jasper.,org.apache.naming.,org.apache.tomcat.'>>$WEB_SERVER_PATH/conf/catalina.properties

RUN echo 'common.loader="${catalina.base}/lib","${catalina.base}/lib/*.jar","${catalina.home}/lib","${catalina.home}/lib/*.jar"'>>$WEB_SERVER_PATH/conf/catalina.properties
RUN echo 'server.loader=' >> $WEB_SERVER_PATH/conf/catalina.properties
RUN echo 'shared.loader="${catalina.home}/shared/lib/*.jar"' >> $WEB_SERVER_PATH/conf/catalina.properties

RUN echo 'tomcat.util.scan.StandardJarScanFilter.jarsToSkip=\
bootstrap.jar,commons-daemon.jar,tomcat-juli.jar,\
annotations-api.jar,el-api.jar,jsp-api.jar,servlet-api.jar,websocket-api.jar,\
jaspic-api.jar,\
catalina.jar,catalina-ant.jar,catalina-ha.jar,catalina-storeconfig.jar,\
catalina-tribes.jar,\
jasper.jar,jasper-el.jar,ecj-*.jar,\
tomcat-api.jar,tomcat-util.jar,tomcat-util-scan.jar,tomcat-coyote.jar,\
tomcat-dbcp.jar,tomcat-jni.jar,tomcat-websocket.jar,\
tomcat-i18n-en.jar,tomcat-i18n-es.jar,tomcat-i18n-fr.jar,tomcat-i18n-ja.jar,\
tomcat-juli-adapters.jar,catalina-jmx-remote.jar,catalina-ws.jar,\
tomcat-jdbc.jar,\
tools.jar,\
commons-beanutils*.jar,commons-codec*.jar,commons-collections*.jar,\
commons-dbcp*.jar,commons-digester*.jar,commons-fileupload*.jar,\
commons-httpclient*.jar,commons-io*.jar,commons-lang*.jar,commons-logging*.jar,\
commons-math*.jar,commons-pool*.jar,\
jstl.jar,taglibs-standard-spec-*.jar,\
geronimo-spec-jaxrpc*.jar,wsdl4j*.jar,\
ant.jar,ant-junit*.jar,aspectj*.jar,jmx.jar,h2*.jar,hibernate*.jar,httpclient*.jar,\
jmx-tools.jar,jta*.jar,log4j*.jar,mail*.jar,slf4j*.jar,\
xercesImpl.jar,xmlParserAPIs.jar,xml-apis.jar,\
junit.jar,junit-*.jar,hamcrest-*.jar,easymock-*.jar,cglib-*.jar,\
objenesis-*.jar,ant-launcher.jar,\
cobertura-*.jar,asm-*.jar,dom4j-*.jar,icu4j-*.jar,jaxen-*.jar,jdom-*.jar,\
jetty-*.jar,oro-*.jar,servlet-api-*.jar,tagsoup-*.jar,xmlParserAPIs-*.jar,\
xom-*.jar' >> $WEB_SERVER_PATH/conf/catalina.properties
RUN echo 'tomcat.util.scan.StandardJarScanFilter.jarsToScan=\
log4j-web*.jar,log4j-taglib*.jar,log4javascript*.jar,slf4j-taglib*.jar' >> $WEB_SERVER_PATH/conf/catalina.properties
RUN echo 'tomcat.util.buf.StringCache.byte.enabled=true' >> $WEB_SERVER_PATH/conf/catalina.properties

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
RUN unzip jce_policy-8.zip -d eidas_src

RUN cp eidas_src/UnlimitedJCEPolicyJDK8/local_policy.jar $JAVA_HOME/jre/lib/security/
RUN cp eidas_src/UnlimitedJCEPolicyJDK8/US_export_policy.jar $JAVA_HOME/jre/lib/security/

RUN echo "#!/bin/bash" >> replace.sh

RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/idp/SignModule_IdP.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/idp/SignModule_IdP.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/idp/EncryptModule_IdP.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/idp/EncryptModule_IdP.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/sp/EncryptModule_SP.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/sp/EncryptModule_SP.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/sp/SignModule_SP.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/sp/SignModule_SP.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/specific/SignModule_SP-Specific.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/specific/SignModule_SP-Specific.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/specific/EncryptModule_SP-Specific.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/specific/EncryptModule_SP-Specific.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/specific/EncryptModule_Specific-IdP.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/specific/EncryptModule_Specific-IdP.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/specific/SignModule_Specific-IdP.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/specific/SignModule_Specific-IdP.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/EncryptModule_Connector.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/EncryptModule_Connector.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/EncryptModule_Service.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/EncryptModule_Service.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/SignModule_Connector.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/SignModule_Connector.xml' >> replace.sh
RUN echo 't=`cat /usr/local/src/eidas/config/tomcat/SignModule_Service.xml`; echo "${t//\\\//}" > /usr/local/src/eidas/config/tomcat/SignModule_Service.xml' >> replace.sh

RUN chmod 777 replace.sh

RUN "./replace.sh"
RUN cp /usr/local/src/eidas/config/tomcat/encryptionConf.xml /usr/local/src/eidas/config/       

RUN echo "#!/bin/bash" >> changeIP.sh
RUN echo "old='localhost:8080'" >> changeIP.sh
RUN echo "new='148.247.201.141:8080'" >> changeIP.sh
RUN echo "grep -rl \$old /usr/local/src/eidas/config/tomcat | xargs sed -i s@\$old@\$new@g" >> changeIP.sh

RUN chmod 777 changeIP.sh
RUN "./changeIP.sh"

WORKDIR /home/server
#EXPOSE 9002
RUN echo "#!/bin/bash" >> start.sh
RUN echo "/usr/local/src/tomcat/bin/catalina.sh start" >> start.sh

RUN chmod +x start.sh
EXPOSE 8080

