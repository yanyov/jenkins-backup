pipeline{
  agent{
    label 'master'
  }
   
  triggers{
    cron('H 0 * * *')
  }

  stages{
    stage('Create jenkin backup and upload to S3'){
      steps{
	sh 'chmod +x ./jenkins-backup.sh'
	sh './jenkins-backup.sh'
      }
    }
  }

  post {
    always {
      deleteDir()
    }
  }
}
