# Cria a variável middlewares para guardar as informações em formato CSV
$middlewares = "Data,Nome,Instalado,Localização,Versão,Status`n"
$date = Get-Date -Format "yyyy/MM/dd"

# JBoss EAP
$jbossPath = "C:\Program Files\jboss-eap-7.1\bin\standalone.bat"
if (Test-Path $jbossPath) {
    $jbossVersion = & "$jbossPath" --version 2>&1 | Select-String -Pattern "JBoss EAP"
    $jbossService = Get-Service -Name "JBossEAP7" -ErrorAction SilentlyContinue
    if ($jbossService) {
        $middlewares += "$date,JBoss EAP,Sim,$jbossPath,$jbossVersion,$($jbossService.Status)`n"
    } else {
        $middlewares += "$date,JBoss EAP,Sim,$jbossPath,$jbossVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,JBoss EAP,Não,não aplicável,não aplicável,não aplicável`n"
}

# Tibco EMS
# Como o Tibco EMS não tem uma instalação padrão no Windows, vamos apenas verificar se a variável de ambiente TIBCO_HOME existe
$tibcoHome = [Environment]::GetEnvironmentVariable("TIBCO_HOME", "Machine")
if ($null -ne $tibcoHome) {
    $tibcoVersion = "não aplicável"  # Não temos como obter a versão diretamente
    $tibcoService = Get-Service -DisplayName "TIBCO EMS" -ErrorAction SilentlyContinue
    if ($null -ne $tibcoService) {
        $middlewares += "$date,Tibco EMS,Sim,$tibcoHome,$tibcoVersion,$($tibcoService.Status)`n"
    } else {
        $middlewares += "$date,Tibco EMS,Sim,$tibcoHome,$tibcoVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,Tibco EMS,Não,não aplicável,não aplicável,não aplicável`n"
}

# Apache (assumindo que estamos procurando pelo servidor HTTP Apache)
$apachePath = "C:\Program Files\Apache Group\Apache2\bin\httpd.exe"
if (Test-Path $apachePath) {
    $apacheVersion = & "$apachePath" -v | Select-String -Pattern "Server version"
    $apacheService = Get-Service -DisplayName "Apache2.4" -ErrorAction SilentlyContinue  # O nome do serviço pode variar
    if ($null -ne $apacheService) {
        $middlewares += "$date,Apache,Sim,$apachePath,$apacheVersion,$($apacheService.Status)`n"
    } else {
        $middlewares += "$date,Apache,Sim,$apachePath,$apacheVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,Apache,Não,não aplicável,não aplicável,não aplicável`n"
}

# Aqui prosseguiríamos com a verificação para os demais middlewares, seguindo a mesma lógica
# As partes específicas a serem alteradas seriam o caminho do programa (se houver um caminho padrão para a instalação), a forma de obter a versão e o nome do serviço.

# Apache HTTP Server
$apacheHttpPath = "C:\Program Files (x86)\Apache Group\Apache2\bin\httpd.exe"
if (Test-Path $apacheHttpPath) {
    $apacheHttpVersion = & "$apacheHttpPath" -v | Select-String -Pattern "Server version" | ForEach-Object { $_ -replace "Server version: Apache\/", "" -replace " \(.*\)", "" }
    $apacheHttpService = Get-Service | Where-Object { $_.DisplayName -like "Apache2*" } 
    if ($null -ne $apacheHttpService) {
        $middlewares += "$date,Apache HTTP Server,Sim,$apacheHttpPath,$apacheHttpVersion,$($apacheHttpService.Status)`n"
    } else {
        $middlewares += "$date,Apache HTTP Server,Sim,$apacheHttpPath,$apacheHttpVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,Apache HTTP Server,Não,não aplicável,não aplicável,não aplicável`n"
}

# JBoss EAP
$jbossEapPath = "C:\Program Files\EAP-7.2.0\bin\standalone.bat"
if (Test-Path $jbossEapPath) {
    $jbossEapVersion = & "$jbossEapPath" --version | Select-String -Pattern "JBoss EAP" | ForEach-Object { $_ -replace "JBoss EAP ", "" }
    $jbossEapService = Get-Service | Where-Object { $_.DisplayName -like "*JBoss EAP*" }
    if ($null -ne $jbossEapService) {
        $middlewares += "$date,JBoss EAP,Sim,$jbossEapPath,$jbossEapVersion,$($jbossEapService.Status)`n"
    } else {
        $middlewares += "$date,JBoss EAP,Sim,$jbossEapPath,$jbossEapVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,JBoss EAP,Não,não aplicável,não aplicável,não aplicável`n"
}

# JBoss Web
$jbossWebPath = "C:\Program Files\jboss-web-7.0.0\bin\version.bat"
if (Test-Path $jbossWebPath) {
    $jbossWebVersion = & "$jbossWebPath" | Select-String -Pattern "JBoss Web" | ForEach-Object { $_ -replace "JBoss Web ", "" }
    $jbossWebService = Get-Service | Where-Object { $_.DisplayName -like "*JBoss Web*" }
    if ($null -ne $jbossWebService) {
        $middlewares += "$date,JBoss Web,Sim,$jbossWebPath,$jbossWebVersion,$($jbossWebService.Status)`n"
    } else {
        $middlewares += "$date,JBoss Web,Sim,$jbossWebPath,$jbossWebVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,JBoss Web,Não,não aplicável,não aplicável,não aplicável`n"
}

# IBM MQ
$mqPath = Get-Command dspmqver -ErrorAction SilentlyContinue
if ($null -ne $mqPath) {
    $mqVersion = & dspmqver | Select-String -Pattern "Version:" | ForEach-Object { $_ -replace "Version:", "" }
    $mqService = Get-Service | Where-Object { $_.DisplayName -like "*IBM MQ*" }
    if ($null -ne $mqService) {
        $middlewares += "$date,IBM MQ,Sim,$mqPath,$mqVersion,$($mqService.Status)`n"
    } else {
        $middlewares += "$date,IBM MQ,Sim,$mqPath,$mqVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,IBM MQ,Não,não aplicável,não aplicável,não aplicável`n"
}

# Apache Kafka
$kafkaPath = "C:\kafka\bin\windows\kafka-server-start.bat"
if (Test-Path $kafkaPath) {
    $kafkaVersion = Get-Content -Path "C:\kafka\bin\windows\kafka-server-start.bat" | Select-String -Pattern "KAFKA_VERSION" | ForEach-Object { $_ -replace ".*KAFKA_VERSION=", "" }
    $kafkaService = Get-Service | Where-Object { $_.DisplayName -like "*Kafka*" }
    if ($null -ne $kafkaService) {
        $middlewares += "$date,Apache Kafka,Sim,$kafkaPath,$kafkaVersion,$($kafkaService.Status)`n"
    } else {
        $middlewares += "$date,Apache Kafka,Sim,$kafkaPath,$kafkaVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,Apache Kafka,Não,não aplicável,não aplicável,não aplicável`n"
}

# Tibco Rendezvous
$tibcoPath = "C:\tibco\rv\8.4\bin\rvd.exe"
if (Test-Path $tibcoPath) {
    $tibcoVersion = & "$tibcoPath" -version 2>&1 | Select-String -Pattern "TIBCO Rendezvous"
    $middlewares += "$date,Tibco Rendezvous,Sim,$tibcoPath,$tibcoVersion,não aplicável`n"
} else {
    $middlewares += "$date,Tibco Rendezvous,Não,não aplicável,não aplicável,não aplicável`n"
}

# Redis
$redisPath = "C:\Program Files\Redis\redis-server.exe"
if (Test-Path $redisPath) {
    $redisVersion = & "$redisPath" --version 2>&1 | Select-String -Pattern "Redis server"
    $redisService = Get-Service -Name "Redis" -ErrorAction SilentlyContinue
    if ($redisService) {
        $middlewares += "$date,Redis,Sim,$redisPath,$redisVersion,$($redisService.Status)`n"
    } else {
        $middlewares += "$date,Redis,Sim,$redisPath,$redisVersion,não aplicável`n"
    }
} else {
    $middlewares += "$date,Redis,Não,não aplicável,não aplicável,não aplicável`n"
}

# IBM Web Query
$webQueryPath = "C:\Program Files\ibm\cognos\"
if (Test-Path $webQueryPath) {
    $middlewares += "$date,IBM Web Query,Sim,$webQueryPath,não aplicável,não aplicável`n"
} else {
    $middlewares += "$date,IBM Web Query,Não,não aplicável,não aplicável,não aplicável`n"
}

# Azul Zing
$zingPath = "C:\Program Files\Zing\"
if (Test-Path $zingPath) {
    $middlewares += "$date,Azul Zing,Sim,$zingPath,não aplicável,não aplicável`n"
} else {
    $middlewares += "$date,Azul Zing,Não,não aplicável,não aplicável,não aplicável`n"
}

# Exibe o resultado final
Write-Output $middlewares

