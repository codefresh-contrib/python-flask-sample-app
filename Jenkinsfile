node{
//define app url for component tests
    def APP_URL=""
    def svcName = 'orders'
    def nsName = "${svcName}-testing-${env.BUILD_NUMBER}"
//clean out build dir
    dir ('build')
    {
        deleteDir()
    }
    stage ('git'){
       checkout scm
    }
    stage ('build+ut'){
    	//this runs unit test (assumes there's a mongo running at 'mongo'
	def gr = tool 'gradle'
	sh "${gr}/bin/gradle build"
        junit 'build/test-results/test/*.xml'
   }
   def image = ''
   stage ('dockerize'){
       image = docker.build "otomato/oto-${svcName}:${env.BUILD_NUMBER}"
   }
    
    stage ('push'){
        image.push()
    }
    stage ('deploy-to-testing'){
          sh "sed -i -- \'s/BUILD_NUMBER/${env.BUILD_NUMBER}/g\' ${svcName}-dep.yml"
		sh "kubectl create namespace ${nsName}"
        sh "kubectl apply -f mongodep.yml --validate=false -n ${nsName}"
        sh "kubectl apply -f ${svcName}-dep.yml --validate=false -n ${nsName}"
        //get app url
        APP_URL = "<pending>"
        sleep 120
        while ( APP_URL == "<pending>"){
            APP_URL = sh returnStdout: true, script: "kubectl get svc ${svcName} --no-headers=true  -n ${nsName} |  awk '{print \$4}'"
             APP_URL = APP_URL.trim()
            
        }
       
        echo "url is ${APP_URL}"
     }
    stage ('component-test'){
       withEnv(["APP_URL=${APP_URL}:8080"]) {
	sh "tests/ct/run.sh"
       }
    }
    stage ('clean-up'){
	sh "kubectl delete ns ${nsName}"
    }
    stage('deploy-to-staging'){
        sh "kubectl apply -f ${svcName}-dep.yml -n staging"  
    }
     stage ('integration-test'){
	def STAGING_FRONT_IP = sh returnStdout: true, script: "kubectl get svc front --no-headers=true  -n staging |  awk '{print \$4}'"
	echo "Staging frontend is at ${STAGING_FRONT_IP}"
	def STAGING_FRONT_URL = "http://" + STAGING_FRONT_IP.trim() + ":3000"
	dir('it'){
	  git 'https://github.com/antweiss/cicd-workshop.git'
	  withEnv(["STAGING_FRONT_URL=${STAGING_FRONT_URL}"]){
	    sh 'ls'
	    sh './integration-tests/run.sh'
	  }  
	} 
    }
    stage('deploy-to-production'){
        sh "kubectl apply -f ${svcName}-dep.yml -n production"  
    }
}
