import jenkins.model.*
import hudson.model.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.*

def jenkins = Jenkins.instance

def jobName = "COSMERIA"
def job = jenkins.getItem(jobName)

if (job == null) {
    println(">>> Creating job: ${jobName}")

    def p = jenkins.createProject(WorkflowJob, jobName)
    def cpsScmDef = new CpsScmFlowDefinition(
        new hudson.plugins.git.GitSCM(
            hudson.plugins.git.GitSCM.createRepoList("https://github.com/brekhoffd/diploma.git", ""),
            [new hudson.plugins.git.BranchSpec("*/main")],
            false,
            [],
            null,
            null,
            []
        ),
        "pve/jenkins/jenkinsfile"
    )
    cpsScmDef.setLightweight(true)
    p.setDefinition(cpsScmDef)
    p.save()

    // Запускаємо перший білд
    println(">>> Triggering first build for ${jobName}")
    p.scheduleBuild2(0)
} else {
    println(">>> Job ${jobName} already exists")
}
