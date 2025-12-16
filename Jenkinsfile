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
    steps {
        echo 'Deploying to Kubernetes...'
        script {
            // Use kubeconfig as a Secret File in Jenkins
            // Add your kubeconfig file as "Secret File" with ID 'kubeconfig-file'
            withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG')]) {
                sh """
                    set -e  # Exit immediately if any command fails

                    echo "Kubeconfig file path: \$KUBECONFIG"
                    kubectl config view --minify
                    kubectl cluster-info

                    # Create namespace if it doesn't exist
                    if ! kubectl get namespace devops >/dev/null 2>&1; then
                        echo "Creating namespace 'devops'..."
                        kubectl create namespace devops
                    fi

                    echo "Applying MySQL deployment..."
                    kubectl apply -f kubernetes/mysql-deployment.yaml -n devops

                    echo "Applying Spring app deployment..."
                    kubectl apply -f kubernetes/spring-deployment.yaml -n devops

                    echo "Restarting Spring app deployment..."
                    kubectl rollout restart deployment spring-app -n devops || echo "Deployment may be newly created"
                """
            }
        }
    }
}



        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    sh """
                        export KUBECONFIG=~/.kube/config
                        kubectl get pods -n devops || echo "Could not list pods"
                        kubectl get svc -n devops || echo "Could not list services"
                        kubectl get deployments -n devops || echo "Could not list deployments"
                    """
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
