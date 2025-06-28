pipeline {
    agent {
        docker {
            image 'python:3.12'  // 使用包含Python的Docker镜像
            args '-v ${WORKSPACE}:/workspace'  // 挂载你的项目目录
        }
    }
    environment {
        // 直接引用凭据 ID（需提前配置）
        GITHUB_TOKEN = credentials('Github') 
    }
    tools {
        allure 'allure_2.34.1' // 必须与全局工具配置中的名称一致
    }
    stages {
        stage('Setup') {
            steps {
                sh 'bash env_install.sh'  // 安装项目依赖
                sh 'nohup python utils/mock_server.py &'  // 后台启动被测试的服务
            }
        }
        stage('Test') {
            steps {
                sh 'python main.py'  // 运行测试
            }
            post {
                always {
                    allure([
                        reportBuildPolicy: 'ALWAYS',
                        results: [[path: 'cache']] // 你的Allure结果目录
                    ])
                }
            }
        }
    }
    post {
        always {
            script {
                def testResult = getTestStatus()
                def emoji = currentBuild.currentResult == 'SUCCESS' ? '✅' : '❌'
                
                addGitHubComment("""
                ${emoji} Jenkins测试${testResult.status}
                
                详细结果: ${RESULT_LINK}
                """)
            }
        }
    }
}

// 获取测试状态摘要
def getTestStatus() {
    def result = [status: '完成', details: '']
    try {
        def testData = junit testResults: '**/target/surefire-reports/TEST-*.xml', allowEmptyResults: true
        if(testData.totalCount > 0) {
            result.status = testData.failCount == 0 ? '通过' : '失败'
            result.details = "（${testData.totalCount}个用例，${testData.failCount}个失败）"
        }
    } catch(e) {
        result.status = '状态未知'
        result.details = '（无法解析测试结果）'
    }
    return result
}

// 添加GitHub评论
def addGitHubComment(String message) {
    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
        def payload = """
        {
            "body": "${message.trim().replaceAll('\n','\\\\n').replaceAll('"','\\\\"')}"
        }
        """
        
        sh """
        curl -s -X POST \
          -H "Authorization: token ${GITHUB_TOKEN}" \
          -H "Accept: application/vnd.github.v3+json" \
          -d '${payload}' \
          "https://api.github.com/repos/${env.GITHUB_REPO}/commits/${env.GIT_COMMIT}/comments"
        """
    }
}
