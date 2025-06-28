pipeline {
    agent {
        docker {
            image 'python:3.12'  // 使用包含Python的Docker镜像
            args '-v ${WORKSPACE}:/workspace'  // 挂载你的项目目录
        }
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
}
