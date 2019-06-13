node {
    stage('Confirmation') {
        verify();
    }
    stage('Copy') {
        step ([$class: 'CopyArtifact', projectName: 'twatter-frontend/feature%2Fjenkins']);
    }
    stage('Build'){
        sh "docker build -t acceptatie:B${BUILD_NUMBER} .";
    }
    stage('Deploy') {
        sh "docker run --name acceptatie -p 4200:4200 -d acceptatie:B${BUILD_NUMBER}";
    }
    stage('Shutdown') {
        sh "echo Deployed application to http://localhost:4200";
        sh "echo To shut down, please click proceed.";
        verify();
        sh "docker rm -f acceptatie";
        sh "echo removing excess containers created by frontend..."
        sh 'docker rm $(docker stop $(docker ps -a -q --filter ancestor=node --format="{{.ID}}"))'
    }
}

def verify() {
    def userInput = input(
        id: 'userInput', message: 'This is PRODUCTION!', parameters: [
        [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: "Please confirm you are sure to proceed"]
    ])

    if(!userInput) {
        error "Action wasn't confirmed";
    }
}