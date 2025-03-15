// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

#include "app_environment.h"
#include "import_qml_components_plugins.h"
#include "import_qml_plugins.h"
#include "PersonDB.h"
#include "Config.h"
#include "FileUtils.h"
#include "SettingsManager.h"

int main(int argc, char* argv[])
{
    set_qt_environment();

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/Logo.png"));
    qmlRegisterType<PersonInfo>("easy.qt.Person", 0, 1, "PersonInfo");
    qmlRegisterType<PersonDB>("easy.qt.PersonDB", 0, 1, "PersonDB");
    qmlRegisterType<Config>("easy.qt.Config", 0, 1, "Config");
    qmlRegisterType<FileUtils>("easy.qt.FileUtils", 0, 1, "FileUtils");
    qmlRegisterType<SettingsManager>("easy.qt.Settings", 0, 1, "SettingsManager");

    QQmlApplicationEngine engine;
    // engine.rootContext()->setContextProperty("ImageOps", new ImageOps);
    const QUrl url(QStringLiteral("qrc:/qt/qml/Main/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
    [url](QObject * obj, const QUrl & objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
