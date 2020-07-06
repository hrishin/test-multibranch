def versionFile = "version2.txt"

@NonCPS
String lattestJenkinsVersion() {
    def test = new XmlSlurper().parse("https://www.jenkins.io/changelog-stable/rss.xml")
    def lts = test.channel.item[0].title.text()
    return lts.split(" ")[1]
}

String currentJenkinsVersion() {
    try {
       return sh(script: 'grep -i "jenkins/jenkins" Dockerfile | cut -d ":" -f2 | grep -o "[0-9.]*"', returnStdout: true)
        //return readFile(file: "version4.txt")
    } catch(e) {
         println "exception"
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
                   echo "c"+ current + " v" + version
                   if(current && current >= version) {
                       echo "no update"
                       return
                   }
                   writeFile(file: "version4.txt", text: version)
                   input message: "Woulkd you like to upgrde jenkins version?"
               }
           }
       }
   }
}
