import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def jenkinsAdminUser = System.getenv('JENKINS_ADMIN_USER')
def jenkinsAdminPassword = System.getenv('JENKINS_ADMIN_PASSWORD')

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def users = hudsonRealm.getAllUsers()
if (!users || users.empty) {
    hudsonRealm.createAccount(jenkinsAdminUser, jenkinsAdminPassword)
    instance.setSecurityRealm(hudsonRealm)
    def strategy = new GlobalMatrixAuthorizationStrategy()
    strategy.add(Jenkins.ADMINISTER, jenkinsAdminUser)
    instance.setAuthorizationStrategy(strategy)
}
instance.save()
