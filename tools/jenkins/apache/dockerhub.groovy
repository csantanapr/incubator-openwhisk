#!groovy
node("ubuntu&&xenial") {
  sh "env"
  sh "docker version"
  sh "docker info"

  stage("Setup") {
    sh "pip install --user --upgrade pip"
    withEnv(['PATH+LOCAL_JENKINS=/home/jenkins/.local/bin']) {
      sh "pip install --user markupsafe"
      sh "pip install --user jsonschema"
      sh "pip install --user couchdb"
      sh "pip install --user ansible==2.3.0.0"
      sh "pip install --user requests==2.10.0"
      sh "pip install --user docker==2.2.1"
      sh "pip install --user httplib2==0.9.2"
    }
    checkout([$class: 'GitSCM',
            branches: [[name: '*/jenkins_experiments']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [
                [$class: 'CleanBeforeCheckout'],
                [$class: 'CloneOption', noTags: true, reference: '', shallow: true]
            ],
            submoduleCfg: [],
            userRemoteConfigs: [[url: 'https://github.com/csantanapr/openwhisk.git']]
        ])
  }

  stage("Build OpenWhisk") {
    def JAVA_JDK_8=tool name: 'JDK 1.8 (latest)', type: 'hudson.model.JDK'

    withEnv(["Path+JDK=$JAVA_JDK_8/bin","JAVA_HOME=$JAVA_JDK_8"]) {
      withCredentials([usernamePassword(credentialsId: 'csantanapr_dockerhub', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USER')]) {
          sh 'docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}'
      }
      
      def dockerhub_prefix = "csantanapr"
      /*
      def PUSH_CMD = "./gradlew distDocker -PdockerRegistry=docker.io -PdockerImagePrefix=${dockerhub_prefix} -x tests:dat:blackbox:badproxy:distDocker -x tests:dat:blackbox:badaction:distDocker -x sdk:docker:distDocker -x tools:cli:distDocker"
      def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
      def shortCommit = gitCommit.take(7)
      sh "${PUSH_CMD} -PdockerImageTag=latest"
      sh "${PUSH_CMD} -PdockerImageTag=${shortCommit}"
      */

    }
  }
  stage("Deploy OpenWhisk") {
    withEnv(['PATH+LOCAL_JENKINS=/home/jenkins/.local/bin']) {
      sh "python --version"
      sh "ansible --version"
      sh "ansible-playbook --version"
      dir('ansible') {
        def dockerhub_prefix = "csantanapr"

        def ANSIBLE_CMD = "ansible-playbook -i environments/local -e docker_image_prefix=$dockerhub_prefix -e docker.port=2376"
        sh "$ANSIBLE_CMD setup.yml"
        sh "$ANSIBLE_CMD couchdb.yml -e mode=clean"
        sh "$ANSIBLE_CMD couchdb.yml"
        sh "$ANSIBLE_CMD initdb.yml"
        sh "$ANSIBLE_CMD wipe.yml"
        sh "$ANSIBLE_CMD apigateway.yml -e mode=clean"
        sh "$ANSIBLE_CMD apigateway.yml"
        sh "$ANSIBLE_CMD openwhisk.yml --become-user=$USER -e mode=clean"
        sh "$ANSIBLE_CMD openwhisk.yml --become-user=$USER"
        sh "$ANSIBLE_CMD postdeploy.yml"
      }
      cat whisk.properties
      sh "docker images | grep openwhisk"
      sh "docker ps"

    }
  }

  stage("Snapshot OpenWhisk CouchDB") {
    def dockerhub_prefix = "csantanapr"
    sh "docker images | grep openwhisk"
    sh "docker ps"
    sh "docker commit couchdb ${dockerhub_prefix}/couchdb-snapshot"
    sh "docker tag ${dockerhub_prefix}/couchdb-snapshot ${dockerhub_prefix}/couchdb-snapshot:latest"
    sh "docker tag ${dockerhub_prefix}/couchdb-snapshot ${dockerhub_prefix}/couchdb-snapshot:${shortCommit}"
    sh "docker push ${dockerhub_prefix}/couchdb-snapshot"
  }



  stage("Clean OpenWhisk") {
    sh "docker ps"
    withEnv(['PATH+LOCAL_JENKINS=/home/jenkins/.local/bin']) {
      dir('ansible') {
        def ANSIBLE_CMD = "ansible-playbook -i environments/local"
        sh "$ANSIBLE_CMD couchdb.yml -e mode=clean"
        sh "$ANSIBLE_CMD apigateway.yml -e mode=clean"
        sh "$ANSIBLE_CMD openwhisk.yml -e mode=clean"
      }
    }
    sh "docker ps"

    sh "docker images"
    sh 'docker rmi -f $(docker images | grep openwhisk | awk \'{print $3}\') || true'
    sh "docker images"
    sh "docker logout"
  }

}
