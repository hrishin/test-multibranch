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
      return [updateJenkins, current, null]
   }
   writeFile(file: "jenkins.txt", text: latestJenkins)
   sh """
   sed -i.bak "s/FROM jenkins\\/jenkins.*/FROM jenkins\\/jenkins:${latestJenkins}-lts-alpine/g\" Dockerfile
   """
   updateJenkins = true
   return [updateJenkins, latestJenkins, jenkinsUpdateMessage(link, description)]
}

def checkPluginUpdates(jenkinsVersion) {
    echo "Checking plugin updates for the Jenkins ${jenkinsVersion}"
    jenkinsVersion = jenkinsVersion.tokenize('.').dropRight(1).join('.')
    def pluginUpdates = new URL("https://updates.jenkins.io/${jenkinsVersion}/update-center.actual.json").getText()
    def pluginsMeta = readJSON text: pluginUpdates
    def updates = []

    readFile('plugins.txt').split('\n').eachWithIndex { plugin, index ->
      (plugin, currentVersion) = pluginInfo.split(':')
      def latestVersion = pluginsMeta['plugins'][plugin]['version']
      if(!latestVersion || currentVersion >= latestVersion) {
         continue
      }
      updates << sprintf("Updating plugin %s from %s to %s version", plugin, currentVersion, latestVersion)
      sh """
      sed -i.bak "s/${pluginInfo}/${plugin}:${latestVersion}/g\" plugins.txt
      """
    }
    def updatePlugins = updates.length > 0 ? true:false
    def releaseNote = updates.length > 0 ? "Plugins updates are available:\n" + updates.join("\n") : null
    return [updatePlugins, releaseNote]
}

pipeline {
   agent any
   stages {
       stage('Check updates') {
           steps {
               script {
                  // check jenkins update
                  (updateJenkins, jenkinsVersion, jenkinsReleaseNote) = checkJenkinsUpdate()
                  // check plugin update
                  (updatePlugins, pluginsReleaseNote) = checkPluginUpdates(jenkinsVersion)
                  println pluginsReleaseNote
               }
           }
       }

       stage('Waiting for the confirmation') {
          when {
             expression { return updateJenkins || updatePlugins}
          }
          steps {
             input message: "Would you like to upgrde Jenkins master?"
          }
       }

       stage('Update jenkins master') {
          when {
             expression {
                expression { return updateJenkins || updatePlugins}
             }
          }
          steps {
            echo "Updating Jenkins master to ${latestJenkins}"
          }
       }
   }
}
