@NonCPS
def lattestJenkinsVersion() {
    def test = new XmlSlurper().parse("https://www.jenkins.io/changelog-stable/rss.xml")
    def data = test.channel.item[0]
    def version = data.title.text().split(" ")[1]
    def link = data.link.text().trim()
    def description = data.description.text().trim().replaceAll("<(.|\n)*?>", '')
    return [version, link, description]
}

String currentJenkinsVersion() {
    try {
       return sh(script: 'grep -i "jenkins/jenkins" Dockerfile | cut -d ":" -f2 | grep -o "[0-9.]*"', returnStdout: true).trim()
    } catch(e) {
         return ""
    }
}

String getLastjenkinsCheck() {
   try {
      return readFile(file: "jenkins.txt")
   } catch(e) {
      return ""
   }
}

String jenkinsUpdateMessage(link, description) {
   return sprintf("```%s```%s", description, link)
} 

def checkJenkinsUpdate() {
   // check jenkins update
   def updateJenkins = false
   def current = currentJenkinsVersion()
   (latestJenkins, link, description) = lattestJenkinsVersion()
   def lastCheck = getLastjenkinsCheck()
      
   println sprintf("current: %s \nlast: %s \nlatest: %s\n", current, lastCheck, latestJenkins)
   if((current && current >= latestJenkins) || (lastCheck && lastCheck >= latestJenkins)) {
      return [updateJenkins, null]
   }
   writeFile(file: "jenkins.txt", text: latestJenkins)
   sh """
   sed -i.bak "s/FROM jenkins\\/jenkins.*/FROM jenkins\\/jenkins:${latestJenkins}-lts-alpine/g\" Dockerfile
   """
   updateJenkins = true
   return [updateJenkins, jenkinsUpdateMessage(link, description)]
}

pipeline {
   agent any
   stages {
       stage('Check updates') {
           steps {
               script {
                  // check jenkins update
                  (updateJenkins, jenkinsReleaseNote) = checkJenkinsUpdate()
               }
           }
       }

       stage('Wait for approval') {
          when {
             expression {
                updateJenkins
             }
          }
          steps {
             input message: "Woulkd you like to upgrde jenkins version?"
          }
       }

       stage('Update jenkins master') {
          when {
             expression {
                updateJenkins
             }
          }
          steps {
            echo "Updating Jenkins to ${latestJenkins}"
          }
       }
   }
}
