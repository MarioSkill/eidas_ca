				#############################################################
				# Dockerfile - eIDAS 1.3.0 					                    #
				# 						      	                            #
				#############################################################

#image build:---> sudo docker build -t ubuntu-eidas .
#docker run -i -t ubuntu-eidas /bin/bash

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
ENV EIDAS_VERSION 1.3.0
ENV TOMCAT_VERSION 8.5.23
ENV WEB_SERVER_PATH /usr/local/src/tomcat


ENV EIDAS_PATH /usr/local/src/eidas
RUN mkdir $EIDAS_PATH

RUN wget https://ec.europa.eu/cefdigital/artifact/content/repositories/eid/eu/eIDAS-node/$EIDAS_VERSION/eIDAS-node-$EIDAS_VERSION.zip
RUN wget http://www-us.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN unzip eIDAS-node-$EIDAS_VERSION.zip -d eidas_src
RUN unzip ./eidas_src/EIDAS-Binaries-Tomcat-1.3.zip -d ./eidas_src/binaries
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
RUN echo "new='163.117.148.105:8080'" >> changeIP.sh
RUN echo "grep -rl \$old /usr/local/src/eidas/config/tomcat | xargs sed -i s@\$old@\$new@g" >> changeIP.sh

RUN chmod 777 changeIP.sh
RUN "./changeIP.sh"

#CMD '/usr/local/src/tomcat/bin/startup.sh'

RUN apt-get update
RUN apt-get install -y build-essential git-core vim curl -y
RUN mkdir /etc/php5ts

ENV PHP_DIRECTORY "/etc/php5ts"  
ENV PHP_TIMEZONE "UTC"  

RUN echo $PHP_DIRECTORY  
RUN echo $PHP_TIMEZONE  

RUN apt-get install -y make autoconf re2c bison
RUN apt-get install -y libicu-dev libmcrypt-dev libssl-dev libcurl4-openssl-dev libbz2-dev libxml2-dev libpng-dev libjpeg-dev libedit-dev -y

WORKDIR /etc/

RUN wget http://dk2.php.net/get/php-5.6.31.tar.gz/from/this/mirror
RUN mv mirror php-5.6.31.tar.gz
RUN tar -zxf php-5.6.31.tar.gz
RUN rm -r php5ts
RUN ls /etc/php-5.6.31
#RUN mv /etc/php-5.6.31 /etc/php5ts
ENV PHP_DIRECTORY "/etc/php-5.6.31"
WORKDIR /etc/php-5.6.31
RUN apt-get install libssl-dev libsslcommon2-dev -y
RUN apt-get install -y autoconf g++ make openssl libssl-dev libcurl4-openssl-dev -y
RUN apt-get install -y libcurl4-openssl-dev pkg-config -y
RUN apt-get install -y libsasl2-dev -y
RUN ./buildconf --force
RUN ./configure --prefix=$PHP_DIRECTORY --with-config-file-path=$PHP_DIRECTORY --with-config-file-scan-dir=$PHP_DIRECTORY/conf.d --disable-all --enable-maintainer-zts --with-curl --with-openssl --with-gd --enable-gd-native-ttf --enable-intl --enable-mbstring --with-mcrypt --with-mysqli=mysqlnd --with-zlib --with-bz2 --enable-exif --with-pdo-mysql=mysqlnd --with-libedit --enable-zip --enable-pdo --enable-pcntl --enable-sockets --enable-mbregex --with-tsrm-pthreads

RUN make
RUN make test
RUN make install
RUN cp php.ini-production /etc/php-5.6.31/php.ini  
WORKDIR /etc
RUN git clone https://github.com/krakjoe/pthreads.git  
WORKDIR /etc/pthreads
RUN git checkout PHP5  
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" >>/etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main">>/etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y php5.6-dev --allow-unauthenticated
RUN phpize
RUN ./configure --with-php-config=$PHP_DIRECTORY/bin/php-config
RUN make  
RUN make test  
RUN make install 
RUN mkdir $PHP_DIRECTORY/conf.d  
RUN echo "extension=pthreads.so" > $PHP_DIRECTORY/conf.d/pthreads.ini  

RUN sed 's#;date.timezone\([[:space:]]*\)=\([[:space:]]*\)*#date.timezone\1=\2\"'"$PHP_TIMEZONE"'\"#g' $PHP_DIRECTORY/php.ini > $PHP_DIRECTORY/php.ini.tmp

RUN mv $PHP_DIRECTORY/php.ini.tmp $PHP_DIRECTORY/php.ini

RUN sed 's#display_errors = Off#display_errors = On#g' $PHP_DIRECTORY/php.ini > $PHP_DIRECTORY/php.ini.tmp

RUN mv $PHP_DIRECTORY/php.ini.tmp $PHP_DIRECTORY/php.ini

RUN sed 's#display_startup_errors = Off#display_startup_errors = On#g' $PHP_DIRECTORY/php.ini > $PHP_DIRECTORY/php.ini.tmp

RUN mv $PHP_DIRECTORY/php.ini.tmp $PHP_DIRECTORY/php.ini

RUN sed 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#g' $PHP_DIRECTORY/php.ini > $PHP_DIRECTORY/php.ini.tmp

RUN mv $PHP_DIRECTORY/php.ini.tmp $PHP_DIRECTORY/php.ini

RUN mkdir /home/server
RUN echo "IyEvZXRjL3BocC01LjYuMzEvYmluL3BocA0KPD9waHANCi8qKg0KKiANCiovDQoNCmNsYXNzIE1vbml0b3JpemFyIGV4dGVuZHMgVGhyZWFkIHsNCglwcml2YXRlICRkYXQ7DQoJcHJpdmF0ZSAkbW9uaXRvcml6YXI7DQoJcHJpdmF0ZSAkY29udGFpbmVyTmFtZTsNCglwdWJsaWMgJHJlc3VsdGFkb3M7DQoJcHJpdmF0ZSAkbmNvcmVzOw0KICAgIHByaXZhdGUgJHByb2NNb2RlbDsNCiAgICBwcml2YXRlICR0b3RhbHJhbTsNCglmdW5jdGlvbiBfX2NvbnN0cnVjdCgkaWQpew0KCQkkdGhpcyAtPmkgPSAxOw0KCQkkdGhpcyAtPiBjb250YWluZXJOYW1lID0gJGlkOw0KCQkkdGhpcyAtPiBtb25pdG9yaXphciA9IHRydWU7DQoJCSR0aGlzIC0+bmNvcmVzPXRyaW0oc2hlbGxfZXhlYygiY2F0IC9wcm9jL2NwdWluZm8gfCBncmVwIHByb2Nlc3NvciB8IHdjIC1sIikpOw0KICAgICAgICAkdGhpcyAtPnByb2NNb2RlbD0gc2hlbGxfZXhlYygiY2F0IC9wcm9jL2NwdWluZm8gfCBncmVwICdtb2RlbCBuYW1lJyB8IHVuaXEgfCBhd2sgJ3twcmludCAkNEZTJDVGUyQ2RlMkOEZTJDEwfSciKTsNCiAgICAgICAgJHRoaXMgLT50b3RhbHJhbSA9IHNoZWxsX2V4ZWMoImNhdCAvcHJvYy9tZW1pbmZvIHwgZ3JlcCBNZW1Ub3RhbDogfCBhd2sgJ3twcmludCAkMi8xMDAwfSciKTsNCgl9DQoJcHVibGljIGZ1bmN0aW9uIGdldE1vbml0b3JpemFyKCl7DQoJCXJldHVybiAkdGhpcy0+bW9uaXRvcml6YXI7DQoJfQ0KCXB1YmxpYyBmdW5jdGlvbiBzZXRNb25pdG9yaXphcigkbW9uaXRvcml6YXIpew0KCQkkdGhpcy0+bW9uaXRvcml6YXIgPSAkbW9uaXRvcml6YXI7DQoJfQ0KCXB1YmxpYyBmdW5jdGlvbiBnZXRDb250YWluZXJOYW1lKCl7DQoJCXJldHVybiAkdGhpcy0+Y29udGFpbmVyTmFtZTsNCgl9DQoJcHVibGljIGZ1bmN0aW9uIHNldENvbnRhaW5lck5hbWUoJGNvbnRhaW5lck5hbWUpew0KCQkkdGhpcy0+Y29udGFpbmVyTmFtZSA9ICRjb250YWluZXJOYW1lOw0KCX0NCglwdWJsaWMgZnVuY3Rpb24gZ2V0UmVzdWx0YWRvcygpew0KCQlyZXR1cm4gJHRoaXMtPnJlc3VsdGFkb3M7DQoJfQ0KCWZ1bmN0aW9uIGdldFNlcnZlck1lbW9yeVVzYWdlKCl7DQoJCSRmcmVlID0gc2hlbGxfZXhlYygnZnJlZScpOw0KCQkkZnJlZSA9IChzdHJpbmcpdHJpbSgkZnJlZSk7DQoJCSRmcmVlX2FyciA9IGV4cGxvZGUoIlxuIiwgJGZyZWUpOw0KCQkkbWVtID0gZXhwbG9kZSgiICIsICRmcmVlX2FyclsxXSk7DQoJCSRtZW0gPSBhcnJheV9maWx0ZXIoJG1lbSk7DQoJCSRtZW0gPSBhcnJheV9tZXJnZSgkbWVtKTsNCgkJJG1lbW9yeV91c2FnZSA9ICRtZW1bMl0vJG1lbVsxXSoxMDA7DQoJCXJldHVybiAkbWVtb3J5X3VzYWdlOw0KCX0NCglmdW5jdGlvbiBnZXRTZXJ2ZXJDcHVVc2FnZSgpew0KCQkjYnkgUGF1bCBDb2xieSAoaHR0cDovL2NvbGJ5LmlkLmF1KSwgbm8gcmlnaHRzIHJlc2VydmVkIDspDQoJCS8vJGxvYWQgPSBzeXNfZ2V0bG9hZGF2ZygpOw0KCQkvLyRyID1zaGVsbF9leGVjKCJncmVwICdjcHUgJyAvcHJvYy9zdGF0IHwgYXdrICd7dXNhZ2U9KCQyKyQ0KSoxMDAvKCQyKyQ0KyQ1KX0gRU5EIHtwcmludCB1c2FnZX0nIik7DQoJCS8vcmV0dXJuIHN0cl9yZXBsYWNlKGFycmF5KCJcciIsICJcbiIpLCAnJywgJHIpOw0KCQkvLyRleGVjX2xvYWRzID0gc3lzX2dldGxvYWRhdmcoKTsNCgkJLy8kZXhlY19jb3JlcyA9IHRyaW0oc2hlbGxfZXhlYygiZ3JlcCAtUCAnXnByb2Nlc3NvcicgL3Byb2MvY3B1aW5mb3x3YyAtbCIpKTsNCgkJLy8kY3B1ID0gcm91bmQoJGV4ZWNfbG9hZHNbMF0vKCRleGVjX2NvcmVzICkqMTAwLCAwKTsNCgkJJGNwdSA9IHJvdW5kKCBzaGVsbF9leGVjKCJtcHN0YXQgfCBncmVwIC1BIDUgXCIlaWRsZVwiIHwgdGFpbCAtbiAxIHwgYXdrIC1GIFwiIFwiICd7cHJpbnQgMTAwIC0gICQgMTJ9J2EiKSwyKTsNCgkJcmV0dXJuICRjcHU7DQoJfQ0KCXB1YmxpYyBmdW5jdGlvbiBydW4oKSB7DQoJCSRpID0wOw0KCQkkY3B1ID0gW107DQoJCSRyYW0gPSBbXTsNCgkJJFBSRVZfVE9UQUw9MDsNCgkJJFBSRVZfSURMRT0wOw0KCQl3aGlsZSAoJHRoaXMtPm1vbml0b3JpemFyID09IHRydWUpIHsNCgkJICAkQ1BVPXNoZWxsX2V4ZWMoInNlZCAtbiAncy9eY3B1XHMvL3AnIC9wcm9jL3N0YXQiKTsNCgkJICAkQ1BVID0gcHJlZ19zcGxpdCgnL1xzKy8nLCB0cmltKCRDUFUpKTsNCgkJICAkSURMRT0kQ1BVWzNdOyAjIEp1c3QgdGhlIGlkbGUgQ1BVIHRpbWUuDQoJCSAgIyBDYWxjdWxhdGUgdGhlIHRvdGFsIENQVSB0aW1lLg0KCQkgICRUT1RBTD0wOw0KCQkgIGZvcmVhY2goJENQVSBhcyAkVkFMVUUpew0KCQkgICAgJFRPVEFMPSRUT1RBTCskVkFMVUU7DQoJCSAgfQ0KCQkgDQoJCSAgIyBDYWxjdWxhdGUgdGhlIENQVSB1c2FnZSBzaW5jZSB3ZSBsYXN0IGNoZWNrZWQuDQoJCSAgJERJRkZfSURMRT0kSURMRS0kUFJFVl9JRExFOw0KCQkgICRESUZGX1RPVEFMPSRUT1RBTC0kUFJFVl9UT1RBTDsNCgkJICAkRElGRl9VU0FHRT0oMTAwMCAqICgkRElGRl9UT1RBTC0kRElGRl9JRExFKS8kRElGRl9UT1RBTCs1KS8xMDsNCgkJICAvL2VjaG8gIlxyQ1BVOiAkRElGRl9VU0FHRVxuIjsNCgkJIA0KCQkgICMgUmVtZW1iZXIgdGhlIHRvdGFsIGFuZCBpZGxlIENQVSB0aW1lcyBmb3IgdGhlIG5leHQgY2hlY2suDQoJCSAgJFBSRVZfVE9UQUw9JFRPVEFMOw0KCQkgICRQUkVWX0lETEU9JElETEU7DQoJCQkkcmFtWyRpXSA9IHJvdW5kKCR0aGlzIC0+IGdldFNlcnZlck1lbW9yeVVzYWdlKCksMik7DQoJCQkkY3B1WyRpXSA9IHJvdW5kKCRESUZGX1VTQUdFLDIpOw0KCQkJLy8kdGhpcyAtPiByZXN1bHRhZG9zWyJSQU0iID0+IFskaSA9PiAkdGhpcyAtPiBnZXRTZXJ2ZXJNZW1vcnlVc2FnZSgpXV07DQoJCQkkaSsrOw0KCQkJdXNsZWVwKDI1MDAwMCk7DQoJCX0NCgkJJHRoaXMgLT4gcmVzdWx0YWRvcz1bDQoJCQkiUkVTUE9OU0UiID0+ICJHRVREQVRBX09LIiwNCgkJCSJDUFVNIiA9PiAkdGhpcyAtPiBwcm9jTW9kZWwsDQoJCQkiVENPUkVTIiA9PiR0aGlzIC0+IG5jb3JlcywNCgkJCSJDUFUiID0+ICRjcHUsDQoJCQkiVFJBTSIgPT4gJHRoaXMgLT4gdG90YWxyYW0sDQoJCQkiUkFNIj0+JHJhbQ0KCQldOw0KCX0NCn0NCiAgDQogIA0KDQoNCi8qDQokYSA9IG5ldyBNb25pdG9yaXphcigxKTsNCiRhLT5zdGFydCgpOw0Kc2xlZXAoMyk7DQokYS0+c2V0TW9uaXRvcml6YXIoZmFsc2UpOw0Kc2xlZXAoMSk7DQokcj0kYSAtPmdldFJlc3VsdGFkb3MoKTsNCmVjaG8gIjxwcmU+IjsNCnByaW50X3IoJHIpOw0KDQoNCiRyZXF1ZXN0ID0gTW9uaXRvcml6YXIoMSk7DQppZiAoJHJlcXVlc3QtPnN0YXJ0KCkpIHsNCiAgICAgDQogICAgLyogZG8gc29tZSB3b3JrICovDQogICAgIA0KICAgIC8qIGVuc3VyZSB3ZSBoYXZlIGRhdGEgKi8NCiAgLy8gICRyZXF1ZXN0LT5qb2luKCk7DQogICAgIA0KICAgIC8qIHdlIGNhbiBub3cgbWFuaXB1bGF0ZSB0aGUgcmVzcG9uc2UgKi8NCiAgICAvL3Zhcl9kdW1wKCRyZXF1ZXN0LT5yZXNwb25zZSk7DQovL30NCg0KDQovLyovDQoNCg0KPz4=" | base64 --decode >> /home/server/Monitorizar.php
RUN echo "IyEvZXRjL3BocC01LjYuMzEvYmluL3BocA0KPD9waHANCnJlcXVpcmVfb25jZSAnTW9uaXRvcml6YXIucGhwJzsNCnNldF90aW1lX2xpbWl0KDApOw0KDQpjbGFzcyBTZXJ2ZXJTb2NrZXQgIHsNCiAgICANCiAgICBwcml2YXRlICRob3N0Oy8vICAgID0gIjEyNy4wLjAuMSI7DQogICAgcHJpdmF0ZSAkcG9ydDsvLyAgICA9IDkwMDE7DQoNCiAgICANCiAgICBmdW5jdGlvbiBfX2NvbnN0cnVjdCgkaG9zdD0iMTI3LjAuMC4xIiwkcG9ydD0gOTAwMikgew0KICAgICAgICAkdGhpcyAtPmhvc3QgPSRob3N0Ow0KICAgICAgICAkdGhpcyAtPnBvcnQgPSRwb3J0Ow0KDQogICAgfQ0KICAgIHB1YmxpYyBmdW5jdGlvbiBnZXRIb3N0ICgpIHsNCiAgICAgICAgcmV0dXJuICR0aGlzIC0+aG9zdDsNCiAgICB9DQogICAgcHVibGljIGZ1bmN0aW9uIGdldFBvcnQgKCkgew0KICAgICAgICByZXR1cm4gJHRoaXMgLT5wb3J0Ow0KICAgIH0NCiAgICBwdWJsaWMgZnVuY3Rpb24gY2hlY2tTdGFkbygpIHsNCiAgICAgICAgJGNvbm5lY3Rpb24gPSBAZnNvY2tvcGVuKCR0aGlzIC0+aG9zdCwgJHRoaXMgLT5wb3J0KTsNCiAgICAgICAgaWYgKGlzX3Jlc291cmNlKCRjb25uZWN0aW9uKSkgew0KICAgICAgICAgICAgZmNsb3NlKCRjb25uZWN0aW9uKTsNCiAgICAgICAgICAgIHJldHVybiAiRU5DRU5ESURPIjsNCiAgICAgICAgfSBlbHNlIHsNCiAgICAgICAgICAgIHJldHVybiAiQVBBR0FETyI7DQogICAgICAgIH0NCiAgICB9DQogICAgcHVibGljIGZ1bmN0aW9uIGluaWNpbygpIHsNCiAgICAgICAgLy8gY3JlYXRlIHNvY2tldA0KICAgICAgICAkc29ja2V0ID0gc29ja2V0X2NyZWF0ZShBRl9JTkVULCBTT0NLX1NUUkVBTSwgMCkgb3IgZGllKCJDb3VsZCBub3QgY3JlYXRlIHNvY2tldFxuIik7DQogICAgICAgIC8vIGJpbmQgc29ja2V0IHRvIHBvcnQNCiAgICAgICAgJHJlc3VsdCA9IHNvY2tldF9iaW5kKCRzb2NrZXQsICR0aGlzIC0+aG9zdCwgJHRoaXMgLT5wb3J0KSBvciBkaWUoIkNvdWxkIG5vdCBiaW5kIHRvIHNvY2tldFxuIik7DQogICAgICAgIC8vIHN0YXJ0IGxpc3RlbmluZyBmb3IgY29ubmVjdGlvbnMNCiAgICAgICAgJHJlc3VsdCA9IHNvY2tldF9saXN0ZW4oJHNvY2tldCwgMykgb3IgZGllKCJDb3VsZCBub3Qgc2V0IHVwIHNvY2tldCBsaXN0ZW5lclxuIik7DQogICAgICAgICRtID0gbmV3IE1vbml0b3JpemFyKDEpOw0KICAgICAgICAvLyBhY2NlcHQgaW5jb21pbmcgY29ubmVjdGlvbnMNCiAgICAgICAgLy8gc3Bhd24gYW5vdGhlciBzb2NrZXQgdG8gaGFuZGxlIGNvbW11bmljYXRpb24NCiAgICAgICAgJHJlcGV0aXIgPXRydWU7DQogICAgICAgIHdoaWxlKCRyZXBldGlyKXsNCiAgICAgICAgICAgICRzcGF3biA9IHNvY2tldF9hY2NlcHQoJHNvY2tldCkgb3IgZGllKCJDb3VsZCBub3QgYWNjZXB0IGluY29taW5nIGNvbm5lY3Rpb25cbiIpOw0KICAgICAgICAgICAgLy8gcmVhZCBjbGllbnQgaW5wdXQNCiAgICAgICAgICAgICRpbnB1dCA9IHNvY2tldF9yZWFkKCRzcGF3biwgMTAyNCkgb3IgZGllKCJDb3VsZCBub3QgcmVhZCBpbnB1dFxuIik7DQogICAgICAgICAgICAvLyBjbGVhbiB1cCBpbnB1dCBzdHJpbmcNCiAgICAgICAgICAgICRpbnB1dCA9IHRyaW0oJGlucHV0KTsNCiAgICAgICAgICAgIGVjaG8gIkNsaWVudCBNZXNzYWdlIDogIi4kaW5wdXQuIlxuIjsNCiAgICAgICAgICAgICRtc2c9ZXhwbG9kZSgiXyIsJGlucHV0KTsNCiAgICAgICAgICAgIGlmKCBzdHJjbXAoJG1zZ1swXSwiTUVESVIiKSA9PT0gMCl7DQogICAgICAgICAgICAgICAgJG0gPSBuZXcgTW9uaXRvcml6YXIoMSk7DQogICAgICAgICAgICAgICAgJG0gLT5zdGFydCgpOw0KICAgICAgICAgICAgICAgICRvdXRwdXQgPXNlcmlhbGl6ZSAoYXJyYXkoIlJFU1BPTlNFIiA9PiAiTUVESVJfT0siKSk7DQogICAgICAgICAgICB9ZWxzZSBpZiAoc3RyY21wKCRtc2dbMF0sIkdFVERBVEEiKT09PTApew0KICAgICAgICAgICAgICAgICAkbSAtPnNldE1vbml0b3JpemFyKGZhbHNlKTsNCiAgICAgICAgICAgICAgICAgc2xlZXAoMSk7DQogICAgICAgICAgICAgICAgICRvdXRwdXQgPXNlcmlhbGl6ZSgkbSAtPmdldFJlc3VsdGFkb3MoKSk7DQogICAgICAgICAgICAgICAgICRtLT5qb2luKCk7DQogICAgICAgICAgICB9ZWxzZSBpZiAoc3RyY21wKCRtc2dbMF0sIlNUQVRVUyIpID09PTApew0KICAgICAgICAgICAgICAgICRvdXRwdXQgPXNlcmlhbGl6ZSAoYXJyYXkoIlJFU1BPTlNFIiA9PiAiU1RBVFVTX09LIikpOw0KICAgICAgICAgICAgfWVsc2UgaWYgKHN0cmNtcCgkbXNnWzBdLCJTVE9QIikgPT09MCl7DQogICAgICAgICAgICAgICAgJG91dHB1dCA9c2VyaWFsaXplIChhcnJheSgiUkVTUE9OU0UiID0+ICJTVE9QX09LIikpOw0KICAgICAgICAgICAgICAgICRyZXBldGlyPWZhbHNlOw0KICAgICAgICAgICAgICAgIC8vc29ja2V0X3dyaXRlKCRzcGF3biwgJG91dHB1dCwgc3RybGVuICgkb3V0cHV0KSkgb3IgZGllKCJDb3VsZCBub3Qgd3JpdGUgb3V0cHV0XG4iKTsNCiAgICAgICAgICAgIH1lbHNlew0KICAgICAgICAgICAgICAgICRvdXRwdXQgPXNlcmlhbGl6ZSAoYXJyYXkoIlJFU1BPTlNFIiA9PiAiREVTQ09OT0NJRE9fT0siKSk7DQogICAgICAgICAgICB9DQogICAgICAgICAgICAkb3V0cHV0Lj0iXHJcbiI7DQogICAgICAgICAgICAvLyByZXZlcnNlIGNsaWVudCBpbnB1dCBhbmQgc2VuZCBiYWNrDQogICAgICAgICAgICAvLyRvdXRwdXQgPSBzdHJyZXYoJGlucHV0KTsNCiAgICAgICAgICAgIHNvY2tldF93cml0ZSgkc3Bhd24sICRvdXRwdXQsIHN0cmxlbiAoJG91dHB1dCkpIG9yIGRpZSgiQ291bGQgbm90IHdyaXRlIG91dHB1dFxuIik7DQogICAgICAgICAgICAvLyBjbG9zZSBzb2NrZXRzDQogICAgICAgIH0NCiAgICAgICAgc29ja2V0X2Nsb3NlKCRzcGF3bik7DQogICAgICAgIHNvY2tldF9jbG9zZSgkc29ja2V0KTsNCiAgICB9DQp9DQokbG9jYWxJUCA9IGdldEhvc3RCeU5hbWUoZ2V0SG9zdE5hbWUoKSk7DQokcyA9IG5ldyBTZXJ2ZXJTb2NrZXQgKCRsb2NhbElQLDkwMDIpOw0KJHMtPmluaWNpbygpOw0KPz4=" | base64 --decode >> /home/server/Server.php


WORKDIR /home/server
#EXPOSE 9002
RUN echo "#!/bin/bash" >> start.sh
RUN echo "/usr/local/src/tomcat/bin/catalina.sh start" >> start.sh
RUN echo "/etc/php-5.6.31/bin/php Server.php" >> start.sh


RUN chmod +x start.sh
EXPOSE 8080
#ENTRYPOINT ""
#ENTRYPOINT "/home/server/start.sh"
