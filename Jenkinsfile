pipeline {
    agent {
        docker {
            image 'python:3.12'
            args '-v ${WORKSPACE}:/workspace'
        }
    }
    environment {
        GITHUB_TOKEN = credentials('Github')
        // 获取 Git 提交 SHA
        GIT_COMMIT = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
        // Jenkins 构建结果 URL
        BUILD_URL = "${env.BUILD_URL}"
    }
    tools {
        allure 'allure_2.34.1'
    }
    stages {
        stage('Setup') {
            steps {
                sh 'bash env_install.sh'
                sh 'nohup python utils/mock_server.py &'
            }
        }
        stage('Test') {
            steps {
                sh 'python main.py'
            }
            post {
                always {
                    allure([
                        reportBuildPolicy: 'ALWAYS',
                        results: [[path: 'cache']]
                    ])
                    
                    script {
                        // 确定测试结果状态
                        def testResult = currentBuild.currentResult
                        def resultEmoji = testResult == 'SUCCESS' ? '✅' : '❌'
                        def resultText = testResult == 'SUCCESS' ? '通过' : '失败'
                        
                        // 构建评论内容
                        def comment = """
                        ${resultEmoji} Jenkins 测试${resultText}
                        
                        构建详情: ${BUILD_URL}
                        Allure 报告: ${BUILD_URL}allure/
                        """
                        
                        // 调用 GitHub API 添加评论
                        withCredentials([usernamePassword(credentialsId: 'Github', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                            sh """
                                curl -s -X POST \
                                -H "Authorization: token ${GITHUB_TOKEN}" \
                                -H "Accept: application/vnd.github.v3+json" \
                                https://api.github.com/repos/a171232886/example_pytest_jenkins/commits/${GIT_COMMIT}/comments \
                                -d '{"body": "${comment}"}'
                            """
                        }
                    }
                }
            }
        }
    }
}
