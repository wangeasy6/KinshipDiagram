#include "Config.h"
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>


Config::Config()
{

    QFile configFd;

#ifndef QT_DEBUG
    QString appLocalDataPath = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    if (!appLocalDataPath.isEmpty())
        m_configPath = appLocalDataPath + "/def_cfg.json";
#endif

    configFd.setFileName(m_configPath);
    if (!configFd.open(QIODevice::ReadWrite | QIODevice::Text)) {
        qDebug() << "[Config] Unable to open: " << m_configPath;
        initTranslator(m_language);
        return;
    }

    QString jsonString;

    QTextStream in(&configFd);
    while (!in.atEnd()) {
        jsonString += in.readLine();
    }
    configFd.close();
    // qDebug().noquote() << jsonString;

    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8());
    if (jsonDoc.isObject()) {
        QJsonObject jsonObj = jsonDoc.object();
        QString _language = jsonObj["language"].toString();
        if (_language == "zh-CN" || _language == "zh-TW")
            m_language = _language;
        initTranslator(m_language);
        QJsonArray history = jsonObj["history"].toArray();
        for (const QJsonValue& value : history) {
            if (value.isString() && m_fileUtils.isFileExist(value.toString())) {
                m_historyList.append(value.toString());
            }
        }
    } else {
        qDebug() << "[Config] Unable to get json object.";
        initTranslator(m_language);
    }
}


bool Config::updatePath(const QString path)
{
    // Get prefix
    QFileInfo fileInfo(path);
    m_dbPath = "file:///" + path;
    m_dbPrefix = "file:///" + fileInfo.dir().path() + "/";

    // Update list
    int index = m_historyList.indexOf(path);
    if (index != -1) {
        m_historyList.removeAt(index);
    }
    m_historyList.insert(0, path);

    // Max length clear
    while (m_historyList.length() > 10)
        m_historyList.removeAt(10);

    return writeJsonBack();
}


bool Config::initTranslator(QString _language)
{
    if (m_translator.load("KinshipDiagramApp_" + _language, "i18n")) {
        qDebug() << "load translator " << _language << " success.";
        QCoreApplication::installTranslator(&m_translator);
        return true;
    }

    qDebug() << "load translator " << _language << "failed.";
    return false;
}


bool Config::setTranslator(QString _language)
{
    QCoreApplication::removeTranslator(&m_translator);
    if (m_translator.load("KinshipDiagramApp_" + _language, "i18n")) {
        qDebug() << "load translator " << _language << " success.";
        QCoreApplication::installTranslator(&m_translator);
        return true;
    }

    qDebug() << "load translator " << _language << "failed.";
    return false;
}


void Config::setLanguage(QString _language)
{
    QString last = m_language;

    if (_language == "zh-CN" || _language == "zh-TW")
        m_language = _language;
    else
        m_language = "zh-CN";       // default

    if (last != m_language) {
        setTranslator(m_language);
        writeJsonBack();
        emit sigLanguageChanged();
    }
}


bool Config::writeJsonBack()
{
    QFile jsonFd(m_configPath);
    if (!jsonFd.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qDebug() << "Unable to open file: " << m_configPath;
        return false;
    }

    QJsonArray historyListJson;
    for (const QString& item : m_historyList) {
        historyListJson.append(item);
    }
    QJsonObject jsonObj;
    jsonObj["language"] = m_language;
    jsonObj["history"] = historyListJson;
    QJsonDocument document(jsonObj);

    jsonFd.write(document.toJson());
    jsonFd.close();

    return true;
}
