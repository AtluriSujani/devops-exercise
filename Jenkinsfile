pipeline {
    parameters {
       choice(name: 'branch_name', choices: ['main','development'], description: 'Select branch name')
       booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    agent any 
    environment {
        // Slack configuration
        SLACK_CHANNEL       = "#terrafrom" 
        SLACK_COLOR_DANGER  = "#E01563" 
        SLACK_COLOR_INFO    = "#6ECADC" 
        SLACK_COLOR_WARNING = "#FFC300" 
        SLACK_COLOR_GOOD    = "#3EB991"
    }    
    options {
      buildDiscarder(logRotator(numToKeepStr: "10"))
  }
    stages {
        stage ('checkout') {
            steps {
                script{
                    git (credentialsId: 'git', url: 'https://github.com/AtluriSujani/devops-exercise',branch: '${branch_name}')
                }
            }
        }
        stage ('terraform init') {
            steps {
                dir("terraform") {
                sh 'terraform init -input=false'
                sh 'pwd;cd /var/lib/jenkins/workspace/private/terraform'
                sh 'rm -rf .terraform/*'
                }
            }
        }
        stage ('terraform plan') {
            steps {
                dir("terraform") {
                sh 'terraform init '
                sh 'terraform plan -input=false -out tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }
        stage ('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            options {
                timeout(time: 1,unit: "MINUTES")
            }    
            steps {
                script {
                    def plan = readFile '/var/lib/jenkins/workspace/private/terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage ('terraform apply') {
            steps {
                dir("terraform") {
                sh 'ls'
                }
            }
        }
    }
post { 
    always {
        echo "One way or another, I have finished" 
        //deleteDir() /* clean up our workspace */ 
    } 
    
    // trigger when successful 
    success { 
        echo "I succeeeded!" 
        slackSend (channel: "${env.SLACK_CHANNEL}", color: "${env.SLACK_COLOR_GOOD}", message: "*SUCCESS:* Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})") 
    } 
    
    // trigger when failed 
    failure { 
        echo "I failed :(" 
        //currentBuild.rawBuild.getLog(10) 
        slackSend (channel: "${env.SLACK_CHANNEL}", color: "${env.SLACK_COLOR_DANGER}", message: "*FAILED:* Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    } 
    
    // trigger when aborted 
    aborted { 
        echo "Build aborted!" 
        slackSend (channel: "${env.SLACK_CHANNEL}", color: "${env.SLACK_COLOR_WARNING}", message: "*ABORTED:* Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    } 
  } 
}
