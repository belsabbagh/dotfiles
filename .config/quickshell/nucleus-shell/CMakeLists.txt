cmake_minimum_required(VERSION 3.16)

project(nucleus-shell VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 COMPONENTS Quick REQUIRED)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(nucleus-shell
    main.cpp
)

qt_add_qml_module(nucleus-shell
    URI nucleus-shell 
    QML_FILES
        shell.qml
    RESOURCES
        img/world.png
)

target_link_libraries(nucleus-shell PRIVATE Qt6::Quick)
