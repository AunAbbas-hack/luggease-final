
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val getBuildDir = File(rootProject.projectDir, "../build")
rootProject.layout.buildDirectory.set(getBuildDir)

subprojects {
    project.layout.buildDirectory.set(File(getBuildDir, project.name))
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}