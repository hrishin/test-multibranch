@NonCPS
String lattestJenkinsVersion() {
    def test = new XmlSlurper().parse("https://www.jenkins.io/changelog-stable/rss.xml")
    def lts = test.channel.item[0].title.text()
    return lts.split(" ")[1]
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

pipeline {
   agent any
   stages {
       stage('check version') {
           steps {
               script {
                  def current = currentJenkinsVersion()
                  def latest  = lattestJenkinsVersion()
                  def lastCheck = getLastjenkinsCheck()
                   
                  println sprintf("current: %s \n last: %s \n latest: %s\n", current, lastCheck, latest)
                  if((current && current >= latest) && (lastCheck && current >= lastcheck)) {
                      echo "no update"
                      return
                  }
                  writeFile(file: "jenkins.txt", text: latest)
                  input message: "Woulkd you like to upgrde jenkins version?"
               }
           }
       }
   }
}
