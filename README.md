# Kubernetes_project

## Overview

The project is a hands-on learning experience with multi-component environment consisting of Jenkins, Ansible, and a web application deployed on a Kubernetes cluster. The primary goal of this project is to gain practical knowledge and proficiency in using these tools and technologies.

The project involves setting up a local environment with three Linux instances. Jenkins is utilized as a CI/CD tool, with the help of ngrok for tunneling and creating a GitHub webhook to automate builds. Ansible as a configuration management tool to manage the Kubernetes service and deployment. The web application is containerized using Docker and deployed on a Kubernetes cluster managed by Minikube.

The pipeline script automates various stages of the build and deployment process. It starts by checking out the project from a GitHub repository, sending project files to the Ansible server, and building a Docker image for the web application. The Docker image is then tagged with version and latest tags before being pushed to a DockerHub repository. Additionally, the project files are copied to the Kubernetes server, and the application is deployed on the Kubernetes cluster using Ansible.

## Pre-requisites

- Git
- Linux
- Jenkins
- Docker
- DockerHub account
- Ansible 
- Kubernetes (Deployment & services)
- *Ngrok (tunnel localhost service)


### 3 Linux instance

1. Jenkins (default-jre + jenkins) * + Ngrok
2. Ansible (python+ansible+docker)
3. Webapp (kubernetes cluster) --> (docker + minikube)

I setup static IP for the VMs in /etc/netplan/...


- IP Jenkins: 192.168.1.49
- IP Ansible: 192.168.1.50
- IP Kubernetes 192.168.1.51


## Pipeline steps

### Git Checkout

```
stage('Git Checkout') {
    git branch: 'main', url: 'https://github.com/alfoldi322/Kubernetes_project.git'
}
```


### Send files to Ansible server

```
stage('Send files to Ansible server') {
    sshagent(['ansible_server']) {
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50'
        sh 'scp -r /var/lib/jenkins/workspace/pipeline_demo/* ubuntu@192.168.1.50:/home/ubuntu/'
    }
}
```


### Build docker image

```
stage('Build docker image') {
    sshagent(['ansible_server']) {
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 cd /home/ubuntu'
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 docker image build -t $JOB_NAME:v1.$BUILD_ID .'
    } 
}
```


### Tag docker image

```
stage('Tag docker image') {
    sshagent(['ansible_server']) {
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 cd /home/ubuntu'
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 docker image tag $JOB_NAME:v1.$BUILD_ID alfoldi322/$JOB_NAME:v1.$BUILD_ID'
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 docker image tag $JOB_NAME:v1.$BUILD_ID alfoldi322/$JOB_NAME:latest'
    }
}
```


### Push docker image to DockerHub

```
stage('Push docker image to DockerHub') {
    sshagent(['ansible_server']) {
        withCredentials([string(credentialsId: 'dockerhub_password', variable: 'dockerhub_password')]) {
            sh "ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 docker login -u alfoldi322 -p ${dockerhub_password}"
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 docker image push alfoldi322/$JOB_NAME:v1.$BUILD_ID'
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 docker image push alfoldi322/$JOB_NAME:latest'
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 docker image rm alfoldi322/$JOB_NAME:v1.$BUILD_ID alfoldi322/$JOB_NAME:latest'
        }
    }
}
```


### Copy files to Kubernetes

```
stage('Copy files to Kubernetes') {
    sshagent(['kubernetes_server']) {
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.51 minikube start'
        sh 'scp -r /var/lib/jenkins/workspace/pipeline_demo/Kubernetes/ ubuntu@192.168.1.51:/home/ubuntu/'
    }
}
```


### Kubernetes deployment with Ansible

```
stage('Kubernetes deployment with Ansible') {
    sshagent(['ansible_server']) {
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 cd /home/ubuntu'
        sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.1.50 ansible-playbook ansible.yml'
    }   
}
```