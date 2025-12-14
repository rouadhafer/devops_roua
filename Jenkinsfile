pipeline {
    agent any

    environment {
        IMAGE_NAME = "rouadhafer/gestion_ue_student"
    }

    stages {

        stage('GitHub Checkout') {
            steps {
                git credentialsId: 'github-credentials',
                    branch: 'main',
                    url: 'https://github.com/rouadhafer/devops_roua.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Docker Push Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $IMAGE_NAME
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(
                    credentialsId: 'jenkins-sonar',
                    variable: 'SONAR_TOKEN'
                )]) {
                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.login=$SONAR_TOKEN \
                    -Dsonar.projectKey=gestion-ue-student
                    '''
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                sh '''
                kubectl apply -f k8s/mysql-deployment.yaml
                kubectl apply -f k8s/springboot-deployment.yaml
                '''
            }
        }
    }
}
