class MyChange {
   String author;
   String msg;
}
@NonCPS
def getChanges()
{
    def changeLogSets = currentBuild.changeSets
    for (int i = 0; i < changeLogSets.size(); i++)
    {
        def entries = changeLogSets[0].items
        for (int j = 0; j < entries.length; j++)
        {
            def entry = entries[0]
            def change = new MyChange()
            change.author = entry.author
            change.msg = entry.msg
            return change
        }
    }

}
def sendNotification()
{
  def subject = "[Pipeline] ${currentBuild.fullDisplayName} : ${currentBuild.currentResult}"
  def content = '${SCRIPT, template="groovy-html.template"}'
  emailext (
    subject: subject,
    body: content,
    mimeType: 'text/html',
    to: "",
    recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']]
  )
}
String cron_string = BRANCH_NAME == "master" ? "H 9 * * *" : ""
@NonCPS
def jsonParse(def json) {
    new groovy.json.JsonSlurperClassic().parseText(json)
}
pipeline {
    options {
        disableConcurrentBuilds()
    }
    agent {
        node {
        label 'ml-platform-unity'
        }
    }
    parameters {
        string(name: 'JIRA_ISSUE_KEY',  defaultValue: 'UnExists',description: 'jira issue key ')
        string(name: 'username', defaultValue: '', description: 'original user who started job')
        string(name: 'isOnlineTag', defaultValue: 'false', description: 'online tag')
    }
    //triggers { cron(cron_string) }
    stages {
        stage('SonarAnalysis') {
            steps {
                 script{
                       echo 'pass SonarAnalysis'
                 }
            }
         }
        stage('Building'){
            steps {
                 script{
                    echo "start"
                    echo "${env.BRANCH_NAME}"
                    echo "${env.BUILD_TAG}"
                    echo "${env.TAG_NAME}"
                    echo "${env.BUILD_USER}"
                    echo "${env.MESSAGE}"
                    echo "${params.isOnlineTag}"
                    echo "${env.gitlabBranch}"
                    echo "${params.username}"
                    echo "${env.gitlabUserName}"

                    USER_NAME = "unknow"
                    if(env.TAG_NAME != null){
                        USER_NAME = sh(returnStdout: true,script:"git show ${env.TAG_NAME} | grep Author | cut -d' ' -f2 ").trim()
                    }else{
                        echo "master change."
                    }
                    echo "${USER_NAME}"
                    LINE_NUMBER = sh(returnStdout: true,script:"git diff ${env.TAG_NAME} origin/master | grep EXTERNAL_VERSION | wc -l").trim()
                    echo "${LINE_NUMBER}"
                    echo "end"
                    build job: 'EXTERNAL_BUILD',parameters: [
                    string(name: 'TAG_NAME',value: String.valueOf("${env.TAG_NAME}")),
                    string(name: 'TRIGGER_NAME',value: String.valueOf("${USER_NAME}")),
                    string(name: 'VERSIONP_CHANGE_NUM',value: String.valueOf("${LINE_NUMBER}"))]
                }
            }
        }
    }
   post {
    always {
       script{
           sendNotification()
      }
    }
     //失败时通知
    failure{
            dingTalk accessToken:'141359be16bb9e24027067a3bca09044a8b71821728682a359626328c9fefcf5',
            jenkinsUrl:'http://ci.mobvista.com/bluedingding',message:"\ntag trigger : ${USER_NAME}",
            imageUrl:'http://cdn-adn.rayjump.com/cdn-adn/v2/portal/19/01/09/18/31/5c35cd9fd5789.png'
            jiraComment(issueKey: "${params.JIRA_ISSUE_KEY}", body: """
            【JENKINS JOB】
               构建结果： {color:red}*FAILURE*{color}
               构建地址：[${env.BUILD_TAG}|${env.BUILD_URL}]
               发起人    ：[~${params.username}]
               ----
               ${ filename="/home/mobdev/jenkins/autotest/${env.BUILD_TAG}/jiraPipeline.log"; if ( fileExists(filename) ){ readFile(filename)}else{"/data/workspace/workspace/Deploy-Dsp-PIPELine-BuildCheck-Test/${env.BUILD_TAG}/jiraPipeline.log文件不存在"} }
               ----
               失败cases：${' 请点击构建链接查看或直接关注钉钉推送 '}
               """)
       
    }
    //成功时通知
    success{
            dingTalk accessToken:'141359be16bb9e24027067a3bca09044a8b71821728682a359626328c9fefcf5',
            jenkinsUrl:'http://ci.mobvista.com/bluedingding',message:"\ntag trigger : ${USER_NAME}",notifyPeople:'',
            imageUrl:'http://cdn-adn.rayjump.com/cdn-adn/v2/portal/19/01/09/18/30/5c35cd5065b3f.png'
            jiraComment(issueKey: "${params.JIRA_ISSUE_KEY}", body: """【JENKINS JOB】
            构建结果： {color:green}*SUCCESS*{color}
            构建地址：[${env.BUILD_TAG}|${env.BUILD_URL}]
            发起人    ：[~${params.username}]
            ----
            ${ filename="/home/mobdev/jenkins/autotest/${env.BUILD_TAG}/jiraPipeline.log"; if ( fileExists(filename) ){ readFile(filename)}else{"/data/workspace/workspace/Deploy-Dsp-PIPELine-BuildCheck-Test/${env.BUILD_TAG}/jiraPipeline.log文件不存在"} }
            ----
            """)
    }
  }
}
