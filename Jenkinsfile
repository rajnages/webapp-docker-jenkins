pipeline {
    agent any
    options {
        parallelsAlwaysFailFast()
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
        skipDefaultCheckout(true)  // For better control of checkout
    }
    tools {
        //jdk 'jdk'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        APP_NAME = "webapp-docker-jenkins"
        RELEASE = "1.0.0"
        DOCKER_USER = "rajnages"
        DOCKER_PASS = 'dockerhub'
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
	    //JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
    }
    stages {
        stage('Initial Setup') {
            parallel {
                stage('clean workspace') {
                    steps {
                        cleanWs()
                    }
                }
                stage('Checkout from Git') {
                    steps {
                        git branch: 'main', url: 'https://github.com/rajnages/webapp-docker-jenkins.git'
                    }
                }
            }
        }

        stage('Analysis and Dependencies') {
            parallel {
                stage('Sonar Analysis') {
                    stages {
                        stage("Sonarqube Analysis") {
                            steps {
                                withSonarQubeEnv('SonarQube-Server') {
                                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=modern-todo-app \
                                    -Dsonar.projectKey=modern-todo-app'''
                                }
                            }
                        }
                        stage("Quality Gate") {
                            steps {
                                timeout(time: 2, unit: 'MINUTES') {
                                    script {
                                        def qg = waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                                        if (qg.status != 'OK') {
                                            echo "Quality Gate status is: ${qg.status}"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                stage('Install Dependencies') {
                    steps {
                        script {
                            sh '''
                                echo "Current directory:"
                                pwd
                                echo "\nDirectory contents:"
                                ls -la
                                echo "\nFinding package.json:"
                                find . -name "package.json"
                                
                                if [ -f "package.json" ]; then
                                    npm install
                                elif [ -f "webapp-docker-jenkins/package.json" ]; then
                                    cd webapp-docker-jenkins && npm install
                                elif [ -f "package.json" ]; then
                                    npm install
                                else
                                    echo "Error: package.json not found"
                                    exit 1
                                fi
                            '''
                        }
                    }
                }
            }
        }

        stage("Docker Operations") {
            stages {
                stage('Build & Push Docker') {
                    steps {
                        script {
                            // Build Image
                            sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                            
                            // Login and Push
                            withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                                sh """
                                    echo \$DOCKERHUB_PASSWORD | docker login -u \$DOCKERHUB_USERNAME --password-stdin
                                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                                    docker push ${IMAGE_NAME}:latest
                                """
                            }
                        }
                    }
                }

                stage('Deploy') {
                    steps {
                        script {
                            sh """
                                docker stop ${APP_NAME} || true
                                docker rm ${APP_NAME} || true
                                docker run -d --name ${APP_NAME} -p 3000:3000 ${IMAGE_NAME}:${IMAGE_TAG}
                            """
                        }
                    }
                }
                
                stage ('Cleanup Artifacts') {
                    steps {
                        script {
                            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                            sh "docker rmi ${IMAGE_NAME}:latest"
                        }
                    }
                }
            }
        }
    }   

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        
        failure {
            echo "Pipeline failed! Check logs for details."
        }
        
        always {
            script {
                // Cleanup workspace
                cleanWs()
                
                // Remove any dangling Docker images
                sh '''
                    docker system prune -f
                    docker image prune -f
                '''
                
                echo "Pipeline finished - cleanup completed"
            }
        }
    }
}