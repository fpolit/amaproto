pipeline{
    environment {
        LOGLEVEL='DEBUG'
        CMAKE_COMPILER_WALL='ON'
        CMAKE_BUILD_TYPE='Debug'
        CMAKE_BUILD_TESTS='ON'

        // Ama-Framework protobuf file
        CMAKE_BUILD_AMADB_PY_PROTO='ON'
        CMAKE_BUILD_AMADB_CXX_PROTO='ON'
        CMAKE_BUILD_AMACONTROLLER_PY_PROTO='ON'
        CMAKE_BUILD_AMACONTROLLER_CXX_PROTO='ON'
        CMAKE_BUILD_AMAPROCESSOR_PROTO='ON'
    }

    agent {
        dockerfile {
            filename "ubuntu20.04-python3.8.dockerfile"
            dir 'data/agents/'
        }
    }

    stages {
        stage('Build') {
            steps {
                sh '''
                mkdir -p build
                cmake -S . -B build -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
                                    -DCMAKE_COMPILER_WALL=${CMAKE_COMPILER_WALL} \
                                    -DCMAKE_BUILD_TESTS=${CMAKE_BUILD_TESTS} \
                                    -DCMAKE_BUILD_AMADB_PY_PROTO=${CMAKE_BUILD_AMADB_PY_PROTO} \
                                    -DCMAKE_BUILD_AMADB_CXX_PROTO=${CMAKE_BUILD_AMADB_CXX_PROTO} \
                                    -DCMAKE_BUILD_AMACONTROLLER_PY_PROTO=${CMAKE_BUILD_AMACONTROLLER_PY_PROTO} \
                                    -DCMAKE_BUILD_AMACONTROLLER_CXX_PROTO=${CMAKE_BUILD_AMACONTROLLER_CXX_PROTO} \
                                    -DCMAKE_BUILD_AMAPROCESSOR_PROTO=${CMAKE_BUILD_AMAPROCESSOR_PROTO} \
                                    --log-level=${LOGLEVEL} || exit 1
                make -C build
                '''
            }
        }
    }
}
