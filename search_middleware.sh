#!/bin/bash

middlewares="Middleware,Instalado,Localização,Versão,Status do Serviço\n"

# Apache HTTP Server
if command -v httpd &> /dev/null
then
    middlewares+="Apache HTTP Server,Sim,$(which httpd) (executável),$(httpd -v | grep 'Server version'),$(systemctl is-active httpd)\n"
else
    middlewares+="Apache HTTP Server,Não,não aplicável,não aplicável,não aplicável\n"
fi

# JBoss EAP
JBOSS_DIR="/opt/jboss/"
if [ -d "$JBOSS_DIR" ]
then
    for dir in $(ls $JBOSS_DIR 2>/dev/null)
    do
        if [[ $dir == jboss-eap-* ]]
        then
            STANDALONE_SH_PATH="$JBOSS_DIR$dir/bin/standalone.sh"
            if [ -f "$STANDALONE_SH_PATH" ]
            then
                JBOSS_VERSION=$(echo $dir | sed 's/jboss-eap-//')
                JBOSS_STATUS=$(bash $STANDALONE_SH_PATH --version 2>&1 | grep 'JBoss EAP')
                middlewares+="JBoss EAP,Sim,$STANDALONE_SH_PATH,$JBOSS_VERSION,$JBOSS_STATUS\n"
            fi
        fi
    done
else
    middlewares+="JBoss EAP,Não,não aplicável,não aplicável,não aplicável\n"
fi

# JBoss Web
if [ -d "/opt/jboss-web/bin" ] && "/opt/jboss-web/bin/standalone.sh" --version 2>/dev/null | grep -q 'JBoss Web'
then
    middlewares+="JBoss Web,Sim,/opt/jboss-web/bin/standalone.sh (executável),$(/opt/jboss-web/bin/standalone.sh --version 2>&1 | grep 'JBoss Web'),$(systemctl is-active jboss-web)\n"
else
    middlewares+="JBoss Web,Não,não aplicável,não aplicável,não aplicável\n"
fi

# IBM MQ
if command -v dspmq &> /dev/null
then
    middlewares+="IBM MQ,Sim,$(which dspmq) (executável),$(dspmq -v | grep 'Version'),$(systemctl is-active mq)\n"
else
    middlewares+="IBM MQ,Não,não aplicável,não aplicável,não aplicável\n"
fi

# Apache Kafka
if command -v kafka-server-start.sh &> /dev/null
then
    middlewares+="Apache Kafka,Sim,$(which kafka-server-start.sh) (executável),$(kafka-server-start.sh --version | grep 'Version'),$(systemctl is-active kafka)\n"
else
    middlewares+="Apache Kafka,Não,não aplicável,não aplicável,não aplicável\n"
fi

# Tibco Rendezvous
if [ ! -z "${TIBRV_HOME}" ] && "${TIBRV_HOME}/bin/tibrv" -version 2>/dev/null | grep -q 'TIBCO Rendezvous'
then
    middlewares+="TIBCO Rendezvous,Sim,${TIBRV_HOME} (variável de ambiente),$(${TIBRV_HOME}/bin/tibrv -version 2>&1 | grep 'TIBCO Rendezvous'),não aplicável\n"
else
    middlewares+="TIBCO Rendezvous,Não,não aplicável,não aplicável,não aplicável\n"
fi

# Oracle WebLogic
if command -v weblogic.Server &> /dev/null
then
    middlewares+="Oracle WebLogic,Sim,$(which weblogic.Server) (executável),$(weblogic.Server -version | grep 'WebLogic Server'),$(systemctl is-active weblogic)\n"
else
    middlewares+="Oracle WebLogic,Não,não aplicável,não aplicável,não aplicável\n"
fi

# IBM MQ
if command -v dspmqver &> /dev/null
then
    middlewares+="IBM MQ,Sim,$(which dspmqver) (executável),$(dspmqver | grep 'Name:'),$(systemctl is-active mq)\n"
else
    middlewares+="IBM MQ,Não,não aplicável,não aplicável,não aplicável\n"
fi

# Apache Kafka
if command -v kafka &> /dev/null
then
    middlewares+="Apache Kafka,Sim,$(which kafka) (executável),$(kafka -version | grep 'kafka_'),$(systemctl is-active kafka)\n"
else
    middlewares+="Apache Kafka,Não,não aplicável,não aplicável,não aplicável\n"
fi

# Redis
if command -v redis-server &> /dev/null
then
    middlewares+="Redis,Sim,$(which redis-server) (executável),$(redis-server --version),$(systemctl is-active redis)\n"
else
    middlewares+="Redis,Não,não aplicável,não aplicável,não aplicável\n"
fi

# IBM Web Query (WQ_SRV)
if command -v wq &> /dev/null
then
    middlewares+="IBM Web Query,Sim,$(which wq) (executável),$(wq --version),$(systemctl is-active wq_srv)\n"
else
    middlewares+="IBM Web Query,Não,não aplicável,não aplicável,não aplicável\n"
fi

# Azul Zing (Java)
if command -v java &> /dev/null
then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    if [[ $JAVA_VERSION == *"Zing"* ]]; then
        middlewares+="Azul Zing,Sim,$(which java) (executável),$JAVA_VERSION,não aplicável\n"
    else
        middlewares+="Azul Zing,Não,não aplicável,não aplicável,não aplicável\n"
    fi
else
    middlewares+="Azul Zing,Não,não aplicável,não aplicável,não aplicável\n"
fi

echo -e $middlewares > middlewares.csv
