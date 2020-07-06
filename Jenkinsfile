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

pipeline {
   agent any
   stages {
       stage('check version') {
           steps {
               script {
                  def current = currentJenkinsVersion()
                  (latest, link, description) = lattestJenkinsVersion()
                  def lastCheck = getLastjenkinsCheck()
                   
                  println sprintf("current: %s \nlast: %s \nlatest: %s\n", current, lastCheck, latest)
                  if((current && current >= latest) && (lastCheck && current >= lastCheck)) {
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
