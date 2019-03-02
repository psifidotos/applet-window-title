cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

find_package(ECM 0.0.11 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)
include(FeatureSummary)

find_package(KF5 "5.40" REQUIRED COMPONENTS
	Declarative
	Plasma
)

plasma_install_package(package org.kde.windowTitle)
