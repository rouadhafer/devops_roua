pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'rouadhafer/gestion_ue_student'
        DOCKER_TAG   = 'latest'
        K8S_NAMESPACE = 'devops'
    }

    stages {
        stage('Git Checkout') {
            steps {
                echo 'Checking out code from Git...'
                checkout scm
            }
        }

        stage('Clean & Compile') {
            steps {
                echo 'Nettoyage et compilation du projet...'
                sh 'mvn clean compile'
            }
        }

        stage('Build with Maven') {
            steps {
                echo 'Building with Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."

                    echo 'Pushing Docker image...'
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {
                        sh '''
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        '''
                    }
                }
            }
        }

       /* stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                withCredentials([
                    file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG')
                ]) {
                    sh '''
                        set -e

                        echo "Using kubeconfig: $KUBECONFIG"
                        kubectl cluster-info

                        # Namespace
                        kubectl get namespace ${K8S_NAMESPACE} >/dev/null 2>&1 || \
                          kubectl create namespace ${K8S_NAMESPACE}

                        echo "Applying MySQL resources..."
                        kubectl apply -f kubernetes/mysql-deployment.yaml -n ${K8S_NAMESPACE}

                        echo "Applying Spring Boot resources..."
                        kubectl apply -f kubernetes/spring-deployment.yaml -n ${K8S_NAMESPACE}

                        echo "Waiting for deployments to be ready..."
                        kubectl rollout status deployment/mysql -n ${K8S_NAMESPACE} --timeout=180s
                        kubectl rollout status deployment/springboot-deployment -n ${K8S_NAMESPACE} --timeout=180s
                    '''
                }
            }
        }*/

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                withCredentials([
                    file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG')
                ]) {
                    sh '''
                        kubectl get pods -n ${K8S_NAMESPACE}
                        kubectl get svc -n ${K8S_NAMESPACE}
                        kubectl get deployments -n ${K8S_NAMESPACE}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
