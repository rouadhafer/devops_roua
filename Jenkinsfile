pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'rouadhafer/gestion_ue_student'
        DOCKER_TAG   = 'latest'
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
                echo 'Nettoyage et compilation du projet'
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
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
                    }
                }
            }
        }

stage('Deploy to Kubernetes') {
    echo 'Deploying to Kubernetes...'
    withCredentials([file(credentialsId: 'kubeconfig-content', variable: 'KUBECONFIG')]) {
        sh 'kubectl apply -f k8s-deployment.yaml'
    }
}

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    sh """
                        export KUBECONFIG=~/.kube/config
                        kubectl get pods -n devops || echo "Could not lis pods"
                        kubectl get svc -n devops || echo "Could not list services"
                        kubectl get deployments -n devops || echo "Could not list deployments"
                    """
                }
            }
        }
    }

    post {
        success {
            echo '? Pipeline completed successfully!'
        }
        failure {
            echo '? Pipeline failed!'
        }
    }
}
